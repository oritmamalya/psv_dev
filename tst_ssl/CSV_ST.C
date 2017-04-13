/*
    Module name: csv_st.c

    The initialization routine of ARCryptoServer

    Notes:
            1. Use the new menu system.
            2. Move IP config code to arintrfc.c
            3. Include the csvinit.c debug code (one line).
            4. Two phases in initialization: first get the key, then
               let the user modify configuration and run.
*/
#include <windows.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#define INCL_DOSSEMAPHORES
#define INCL_DOSPROCESS

#include "arcs.h"
#include "env.h"
#include "config.h"
#include "confdat.h"
#include "msgctl.h"
#include "arsvhelp.h"                   /* ARCryptoKit helper functions */
#include "arsvini.h"
#include "basicmsg.m"
#include "arintrfc.h"
#include "csvglob.h"
#include "userlist.h"
#include "tamperpsv4.h"
#include "psvmbapi.h"
#include "dosstub.h"
#include "userext.h"
#include "kek_db.h"
#include "psvsnmp.h"
#include "management.h"
#include "dblog.h"

// maximal amount of exteded modules
#define MAX_EXT_MOD 10
// implemented in csv1st
int PSVAPI weak_key(unsigned char *key, int len);

static  HANDLE			ARCS_Sem = NULL;
static	HANDLE			ALTERNATE_Sem = NULL;

// all handles of new extended modules are put inide array
static  HANDLE			phMod[MAX_EXT_MOD]={0};

/* ------------------------- LOCAL HELPER FUNCTIONS ------------------------ */
static void csv_create_menus ( void );

static void XOR_SVMK               ( unsigned char dst[MASTER_KEYS_LEN] , unsigned char src[MASTER_KEYS_LEN] );
static void convert_SVMK           ( unsigned char dst[MASTER_KEYS_LEN] , char * src );
static int  SVMK_from_startup_card ( unsigned char SVMK[MASTER_KEYS_LEN] ,
                                     unsigned char SVMK_rest[MASTER_KEYS_LEN]);

static unsigned char ascii_hex_to_bin ( char src );
static int verify_there_was_no_tamper ();

static  MENU_ACTION get_out (int Code, int Id);

/* ------------------------- LOCAL VARIABLES ------------------------ */

static int Init_Option_Id;     /* Startup menu int           option Id */
static int Startup_Option_Id;  /* Startup menu startup       option Id */
static int Rebuild_Option_Id;  /* Startup menu rebuild       option Id */
static int Config_Option_Id;   /* Startup menu configuration option Id */
static int Lock_Option_Id;	   /* Startup menu lock			 option Id */
static int Manual_Option_Id;   /* Startup menu manual        option Id */
#ifndef NON_FIPS
static int reset_tamper_Option_Id; /* Startup menu reset tamper       option Id */
#endif

static int Extended_Option_Id[MAX_EXT_MOD]={0};/* Startup menu extended      option Id */
static int Back_Option_Id;     /* Startup menu back (exit)   option Id */
static int Back_Option_Id_M;   /* Main menu back (exit)      option Id */
static int Shutd_Option_Id;    /* Main menu shutdown         option Id */
static int Run_Option_Id;      /* Startup Menu Let run       option Id */
static int SetPass_Option_Id;  /* Main menu set password     option id */

static HEV  Init_Event;         /* Init Event semaphor handle.       */
static int  Ckit_Started = False; /* Ckit_start successfull flag.       */

static int disable_init_options ( void );
int PSVAPI raise_sem() ;

// new function added for PSV4
static int get_tampering_value(unsigned char *SVMK,
							   unsigned char *tampering_value);
static int read_startup_card(unsigned char Svmk[MASTER_KEYS_LEN], char * headline);

int get_function_add(void	**p_func,
					 HANDLE	*phMod,
					 char	*FuncName);
int is_extfunc_dll_exist(char	*extfunc_dll_name,
						 int	*is_extfunc_dll_loaded,
						 HANDLE	*phMod,
						 char   *Title);

// flags indicates if newly extended modules are loaded.
static 	int	is_extfunc_dll_loaded[MAX_EXT_MOD]={0};

typedef int (*CSV_EXTFUNC)();
typedef void (*CSV_TITLEFUNC)(char *title);

int syslog_configure_internal(int get_or_set, char dest_ip[32]);

#define Max_Attempts 20

// -------------------------------------------------------------------
//	  csv_startup
//
//    This routine is called only once after initialization of the process
//    and before ARCryptoServer is ready to handle client requestes
//
//    Notes:
//       operation modes Update and Diagnose are not implemented
//       in this stage.
//
//       This function may terminate the run by calling exit(0).
// -------------------------------------------------------------------
void    csv_startup ( void )
{
    int            rc, i, errScr=-1;
	char	msg[100];

	// Perform system help functions initialization
	if (csvh_init_helpers ()) // init all helper subsystems
        return;

	// Read the config file data to the local structure
	if (ArConfRead(False))
	{
		rc = 1;
		_csvh_err("Start PrivateServer", csvh_msg(ERR_BAD_RC),  "csv_startup", "ArConfRead", rc);
        get_out(0, 0);
	}


	// Try to init the ARCryptoKit support up to the success
    i = Max_Attempts;

	// Initialize the sadaptor, if failed try 20 times
    while (!(Ckit_Started = (ckit_start () == CSV_OK)))
	{
		_csvh_err("Start PrivateServer Error", "ckit_start() failed i iteration is %d" , i);

		if (!i--)
			get_out(0, 0);
    }

	// Create, post and wait for the main menu
    if ((rc = DosCreateEventSem(NULL, &Init_Event, 0, 0)) == NO_ERROR)
	{
        csv_create_menus();

        if ((rc = DosWaitEventSem(Init_Event, SEM_INDEFINITE_WAIT)) != NO_ERROR)
		{
			_csvh_err("Start PrivateServer", csvh_msg(ERR_BAD_RC),  "csv_startup", "DosWaitEventSem", rc);
            get_out(0, 0);
        }
    }
    else
	{
		_csvh_err("Start PrivateServer", csvh_msg(ERR_BAD_RC),  "csv_startup", "DosCreateEventSem", rc);
        get_out(0, 0);
    }

	// We finished with the pkcs11 functions so it is now ok to call Finalize
	if (Ckit_Started)
		ckit_end();

    csvh_msg_config();     // Get message control configuration.

    csvh_scr_clr (Status_Scrn);
}

/* ------------------------- LOCAL HELPER FUNCTIONS ------------------------ */


/* ======================== MENU OPTION FUNCTIONS ========================== */

static  MENU_ACTION screen_saver (int Code, int Id)
{
	int rc=0;

	// stop the display for screen saver
	stop_display(1);
	_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"screensaver\" enabled=\"true\" >");
	rc = csvh_kbd_key(CSV_FLG_DEFAULT);

	// start again the display
	_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"screensaver\" enabled=\"false\" >");
	start_display(1);

	return Menu_Ok;
}

// -------------------------------------------------------------------
// choice_lock
//
//	Routine description:
//	   Lock or UnLock the Screen Manually.
//
//	Arguments:
//		Code - Not used
//		Id - Not used.
//
//	Returns:
//		Menu_Ok (back to menu).
// -------------------------------------------------------------------
static  MENU_ACTION choice_lock (int Code, int Id)
{
	 int  Operator=0, Scr, rc=0;
	 char *headline = "PrivateServer Locked";
	 unsigned char serial_num[12] ={0};

	 cs_get_serial(serial_num);

	 Scr = csvh_scr_open();
	 csvh_scr_set(Scr);
	 send_snmp_trap(PSV_SNMP_LOCK);

	 if (Code == TIMEOUT_OPTION)
		screen_saver(Code, Id);
	while (!Operator)
	{
		csvh_scr_clr(CSVH_SCR_CURRENT);

		csvh_scr_printf(CSVH_SCR_CURRENT, MSG_HEADER, "LockScr", headline);
		_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"gelbutton\" name=\"unlock\" width=\"180\" height=\"180\" posx=\"313\" posy=\"149\" image=\"unlock\" imagealign=\"Center\" >");
		_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"roundrect\" name=\"PasswordBox\" width=\"670\" height=\"150\" posx=\"80\" posy=\"290\" text=\" Press to unlock PrivateServer \" fontsize=\"26\" fontstyle=\"B\"  withbackground=\"false\"  forecolor=\"14,96,141\" imagekey=\"P\"  textalign=\"MiddleCenter\" locked=\"true\" checked=\"true\" >");
		_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"roundrect\" name=\"SerialNumber\" width=\"400\" height=\"50\" posx=\"370\" posy=\"500\" text=\" S/N: %s \" fontsize=\"14\" withbackground=\"false\"  forecolor=\"14,96,141\" imagekey=\"P\"  textalign=\"MiddleRight\" locked=\"true\" checked=\"true\" >",serial_num);
		do
		{
			rc = csvh_kbd_key_timeout (CSV_FLG_DEFAULT, KBD_TIMEOUT_MILIS);

			// If timeout has occured activate screen saver and wait for key again.
			if (rc == TIMEOUT_OPTION)
				screen_saver(Code, Id);
		} while (rc != 'u');

		Operator = verify_operator(NULL, MANUAL_PSW, "Unlock PrivateServer");
		if (Operator == TIMEOUT_OPTION)
			screen_saver(Code, Id);
		else if (!Operator)
			_csvh_err(headline, csvh_msg(MSG_FAILED_VERIFY_OPERATOR));

	}
	send_snmp_trap(PSV_SNMP_UNLOCK);
	csvh_scr_close(Scr);
	return Menu_Ok;
}

// -------------------------------------------------------------------
// choice_passwd
//
//	Routine description:
//		Set or clear unattended mode. Starting from version 4.8 unattended
//		mode saves in the tamper the two halves of the SVMK key from Init
//		and Startup smart cards
//
//	Arguments:
//		Code - Not used
//		Id - Not used.
//
//	Returns:
//		Menu_Ok (back to menu).
// -------------------------------------------------------------------
static  MENU_ACTION choice_passwd (int Code, int Id)
{
	unsigned char unatt[MASTER_KEYS_LEN+1];
    int  rc=0, Scr;
	char *cancelHeader = "Cancel Unattended Mode", *setHeader = "Set Unattended Mode";

	rc = cs_get_unatt_data(unatt);
	if (rc)
	{
		csvh_err (ERR_FLG_LOG, ERR_WORK_WITH_TAMPER, rc);
		_csvh_scr_err(cancelHeader, csvh_msg(MSG_NOT_SET_UNATTEN_MODE), rc);
		return Menu_Ok;
	}

	// open window for UNATTENDED Messages
	Scr = csvh_scr_open();
	csvh_scr_set(Scr);

	// if password is already defined
    if (unatt[0] == 1)
	{
		// remove password
		rc = _csvh_yesno(True, cancelHeader ,csvh_msg(MSG_UNATTEN_REMOVE));
		if (rc == TIMEOUT_OPTION)
		{
			csvh_scr_close(Scr);
			return Menu_Ok;
		}
        else if (rc)
		{
            memset(unatt, 0, MASTER_KEYS_LEN+1);
			rc = cs_set_unatt_data(unatt);
			if (rc)
			{
				csvh_err (ERR_FLG_LOG, ERR_WORK_WITH_TAMPER, rc);
				_csvh_err(cancelHeader, csvh_msg(MSG_NOT_SET_UNATTEN_MODE), rc);
				csvh_scr_close(Scr);
				return Menu_Ok;
			}
			_csvh_succ(cancelHeader, csvh_msg(MSG_UNATTEN_REMOVED));
			send_snmp_trap(PSV_SNMP_REMOVE_UNATTENDEDMODE);
			csvh_scr_close(Scr);
            return Menu_Ok;
        }
		else // leave password as is
		{
			_csvh_warning(cancelHeader, csvh_msg(MSG_UNATTEN_NOT_REMOVED));
			csvh_scr_close(Scr);
			return Menu_Ok;
		}
    }

	// define unattended password
    if (verify_operator_ext(NULL, SET_UNATTEND_PSW, unatt+1, setHeader))
	{
		// startup card was verified
		unatt[0] = 1;
        rc = cs_set_unatt_data(unatt);
		memset(unatt, 0, MASTER_KEYS_LEN+1);
		if (rc)
		{
			csvh_err (ERR_FLG_LOG, ERR_WORK_WITH_TAMPER, rc);
			_csvh_err(setHeader, csvh_msg(MSG_NOT_SET_UNATTEN_MODE), rc);
			csvh_scr_close(Scr);
			return Menu_Ok;
		}
        else
		{
			csvh_err (ERR_FLG_LOG, MSG_UNATTEN_LOGOK);
			_csvh_succ(setHeader, csvh_msg(MSG_UNATTEN_DONE));
			send_snmp_trap(PSV_SNMP_SET_UNATTENDEDMODE);
			csvh_scr_close(Scr);
            return Menu_Ok;
        }
    }
	else
		_csvh_err(setHeader, csvh_msg(MSG_FAILED_VERIFY_OPERATOR));

	csvh_scr_close(Scr);
    return Menu_Ok;
}


// -------------------------------------------------------------------
//	Print_Prel
//
//	Routine description:
//		Prints the list of the current preloaded modules
//
//	Arguments:
//		l - Number of preloaded modules in the list
//
//	Returns:
//		none.
// -------------------------------------------------------------------
static void Print_Prel ( int l )
{
    int j;
	int posx[8] = {48, 430, 48, 430, 48, 430, 48, 430};
	int posy[8] = {130, 130, 209, 209, 293, 293, 377, 377};

	struct Global_data* Pglobal_data = GPglobal_data();

    if (Pglobal_data->Prel_Sec_Length > 0)
	{
        for (j = 0; j < 8; j++)
		{
			// The first three modules have to be locked (since they cannot be removed)
			if (j < 3)
				_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"roundrect\" name=\"Pre%d\"\" width=\"320\" height=\"60\" posx=\"%d\" posy=\"%d\" locked=\"true\" checked=\"false\" text=\" %s\" textalign=\"MiddleLeft\" backcolor=\"13,95,142\" forecolor=\"255, 255, 255\" bordercolor=\"13,95,142\"  imagekey=\"%d\" >", j+1, posx[j], posy[j], Pglobal_data->Prel_List[j], j+1);

			// The other modules have to clickable
			else if (j < l)
				_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"roundrect\" name=\"Pre%d\"\" width=\"320\" height=\"60\" posx=\"%d\" posy=\"%d\" locked=\"false\" checked=\"false\" text=\" %s\" textalign=\"MiddleLeft\" backcolor=\"13,95,142\" forecolor=\"255, 255, 255\" bordercolor=\"13,95,142\" imagekey=\"%d\" >", j+1, posx[j], posy[j], Pglobal_data->Prel_List[j], j+1);

			// The empty buttons have to be locked.
			else
				_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"roundrect\" name=\"Pre%d\"\" width=\"320\" height=\"60\" posx=\"%d\" posy=\"%d\" locked=\"true\" checked=\"false\" text=\"\" textalign=\"MiddleLeft\" backcolor=\"13,95,142\" forecolor=\"255, 255, 255\" bordercolor=\"13,95,142\" imagekey=\"%d\" >", j+1, posx[j], posy[j], j+1);
		}
	}
}

// -------------------------------------------------------------------
//	addPrelScreen
//
//	Routine description:
//		open new screen for adding new preloaded modules
//
//	Arguments:
//		in_buf - return the input buffer from user
//		screenNum - number of the new screen
//
//	Returns:
//		in_buf
// -------------------------------------------------------------------
int addPrelScreen(char in_buf[])
{
	int			addScr = -1, rc = 0, i = 0;
	char		*inputBuff;


	addScr = csvh_scr_open();
    csvh_scr_set(addScr);

	csvh_scr_printf(CSVH_SCR_CURRENT, MSG_HEADER, "AddPreLoaded", "Add Pre-Loaded Module");
	_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"textbox\" name=\"AddPreMod\" width=\"270\" height=\"60\" posx=\"490\" posy=\"117\" allowedchars=\"A\" forecolor=\"14,96,141\" maxlength=\"8\" fontsize=\"22\" >");
	_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"roundrect\" name=\"Msg\" width=\"460\" height=\"70\" posx=\"35\" posy=\"100\" locked=\"true\" checked=\"true\" text=\"Enter the name of module to add: \" textalign=\"MiddleLeft\" fontstyle=\"B\" forecolor=\"13,95,142\" withbackground=\"false\" >");
 	_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"gelbutton\" name=\"OK\" width=\"85\" height=\"85\" posx=\"685\" posy=\"182\"  image=\"ok\" imagealign=\"Center\" event=\"1\" imagekey=\"\n\" >");
	_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"gelbutton\" name=\"Back\" width=\"85\" height=\"85\" posx=\"590\" posy=\"182\" image=\"back\" imagealign=\"Center\" imagekey=\"\x1B\" >");

	// get string until the NewLine button press
	rc = csvh_kbd_gets (in_buf, 30 - 1, 0, KBD_TIMEOUT_MILIS);

	// Check validity of the input
	inputBuff = in_buf;
	while (inputBuff[i])
	{
		// Check if the module name contains only numbers or characters or underscore character
		if ((inputBuff[i] < '0' || inputBuff[i] > '9') && (inputBuff[i] != '_') && (inputBuff[i] != '-') &&
			(inputBuff[i] < 'A' || inputBuff[i] > 'Z') && (inputBuff[i] < 'a' || inputBuff[i] > 'z'))
		{
			rc = _csvh_err("Add Pre-Loaded Module", "The module name entered contains\n invalid characters. ");
			if (rc != TIMEOUT_OPTION)
				rc = -1;
			break;
		}
		i++;
	}
	csvh_scr_close (addScr);
	return rc;
}


// -------------------------------------------------------------------
//	choice_prel
//
//	Routine description:
//		Display all the preloaded modules menu
//
//	Arguments:
//		Code - Not used
//		Id - Not used.
//
//	Returns:
//		Menu_Ok (back to menu).
// -------------------------------------------------------------------
static  MENU_ACTION choice_prel (int Code, int Id)
{
    int         Deleted = False, Added = False, modulesToDelLen=0, pos, cleared=1;
    int         rc, Next, j,cl, i, exist = False;
    int         sl, nb, commandIndex=0;
    char        in_buf[30], buf[30];
    Module_Name *temp;
    int         Save_on_Init = True;
	char		key_spec[3] = {'a', 'd', '\n'}, headline[19] = "Pre-Loaded Modules";

	ScrnOvl  Scr;
	struct Global_data* Pglobal_data = GPglobal_data();

    Code += Id; // Just to avoid warnings.

    Next = cl = Pglobal_data->Prel_Sec_Length / sizeof(Pglobal_data->Prel_List[0]);

	Scr = csvh_scr_open();
    csvh_scr_set(Scr);
 	csvh_scr_printf(CSVH_SCR_CURRENT, MSG_HEADER, "PreLoaded", "Pre-Loaded Modules");

	// If at least one preloaded module is in the list, show delete instruction line
    if (Next > 0)
	{
		csvh_scr_printf(CSVH_SCR_CURRENT, MSG_IPROUTE_INST2);
		_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"roundrect\" name=\"DeleteL\" width=\"140\" height=\"70\" posx=\"267\" posy=\"465\" text=\"Delete\" textalign=\"Center\" fontstyle=\"B\" forecolor=\"White\" withbackground=\"false\" >");
	}

	// add buttons to the screen (include add buttons, ok & back buttons)
    csvh_scr_printf(CSVH_SCR_CURRENT, MSG_IPROUTE_INST1);
	_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"roundrect\" name=\"AddL\" width=\"70\" height=\"70\" posx=\"115\" posy=\"465\" text=\"Add\" textalign=\"Center\" fontstyle=\"B\" forecolor=\"White\" withbackground=\"false\" >");
 	_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"gelbutton\" name=\"OK\" width=\"85\" height=\"85\" posx=\"685\" posy=\"460\" image=\"ok\" imagealign=\"Center\" imagekey=\"\n\" >");
	_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"gelbutton\" name=\"Back\" width=\"85\" height=\"85\" posx=\"590\" posy=\"460\" image=\"back\" imagealign=\"Center\" imagekey=\"\x1B\" >");

	// add 8 clickable buttons to the screen that contains the preloaded modules
	Print_Prel(Next);

	// Until here we built the screen, from now we need just to update the values in the screen
	// So in every iteration we allways start to update to this current position
	csvh_scr_getcurpos (CSVH_SCR_CURRENT, NULL, &pos);

	while (1)
	{
		exist = False;

		// if we need to update the new values in the screen
		// all the data until pos will be erased, and all to the commands after commandUpdate will be activated
		if (!cleared)
		{
			csvh_scr_clear_pos(CSVH_SCR_CURRENT, pos);
			commandIndex = (commandIndex + 1) % 0xff;
			_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"commandUpdate\" name=\"%d\">", commandIndex);
		}

		// update for each button the text and if to be clickable or not.
		for (j = 0; j < 8; j++)
		{
			if ((j>=3) && (j < Next))
				_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"update\" name=\"Pre%d\" text=\" %.8s\" locked=\"false\" checked=\"false\" imagekey=\"%d\" >", j+1, Pglobal_data->Prel_List[j], j+1);
			else if (j>=3)
				_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"update\" name=\"Pre%d\" text=\"\" locked=\"true\" checked=\"false\" imagekey=\"%d\" >", j+1, j+1);
        }
		cleared=0;

		memset(in_buf, 0, sizeof(in_buf));
		memset(buf, 0, sizeof(buf));

		// Wait for input from user (until pressed add\delete button or
		// ok\back button specified by key_spec)
		rc = csvh_kbd_gets_spec (in_buf, sizeof (in_buf) - 1, 0, KBD_TIMEOUT_MILIS, key_spec, 3);

		// ESC was pressed or timeout was reached recover from file
		if ((rc == CANCEL_OPTION) || (rc == TIMEOUT_OPTION))
		{
		if (Pglobal_data->Prel_List != NULL)
				FreeMem(Pglobal_data->Prel_List);

			// No default (empty list)
            Pglobal_data->Prel_List = NULL;
            Pglobal_data->Prel_Sec_Length = 0;
            if (rc = ArConfGetSection(Prel_SecName, (void *)&(Pglobal_data->Prel_List), &(Pglobal_data->Prel_Sec_Length), &Save_on_Init))
			{
				_csvh_err(headline, csvh_msg(ERR_NO_PREL_SEC), rc);
			}
			csvh_scr_close (Scr);
            return Menu_Ok;
        }
		if (in_buf[0] == '\n')
			break;
		sl = strlen(in_buf);

        nb = 1;
		// The user insert a or A means that he want to add new preloaded module to the list
        if ((in_buf[sl-1] == 'a') || (in_buf[sl-1] == 'A'))
		{
			memset(in_buf, 0, sizeof(in_buf));
			if (Next+1 <= 8)
				rc = addPrelScreen(in_buf);
			else
				_csvh_scr_err(headline, "The pre-loaded module list contains \n the maximum modules number!");

			if (rc == TIMEOUT_OPTION)
			{
				if (Pglobal_data->Prel_List != NULL)
				FreeMem(Pglobal_data->Prel_List);

				// No default (empty list)
				Pglobal_data->Prel_List = NULL;
				Pglobal_data->Prel_Sec_Length = 0;
				if (rc = ArConfGetSection(Prel_SecName, (void *)&(Pglobal_data->Prel_List), &(Pglobal_data->Prel_Sec_Length), &Save_on_Init))
				{
					_csvh_err(headline, csvh_msg(ERR_NO_PREL_SEC), rc);
				}
				csvh_scr_close (Scr);
				return Menu_Ok;
			}
			else if ((rc != -1) && (in_buf[1] != '\0'))
			{
				for (j=0; j<Next; j++)
				{
					if (memcmp(Pglobal_data->Prel_List[j], in_buf+1, strnlen(in_buf+1, 8)) == 0)
					{
						exist = True;
						break;
					}
				}
				if (exist)
				{
					_csvh_scr_err(headline, "Module already exists in the \n preloaded module list!");
					continue;
				}

				if (Next == cl)
				{
					// Allocate space for one more preloaded module
					temp = GetMem((Next+1) * sizeof(Module_Name),"choice_prel");
					if (Pglobal_data->Prel_List != NULL)
					{
						memcpy(temp, Pglobal_data->Prel_List, Pglobal_data->Prel_Sec_Length);
						FreeMem( Pglobal_data->Prel_List);
					}
					Pglobal_data->Prel_List = temp;
					cl++;
				}

				// We get the module name in upper case from the screen and change it
				// to lower case for compatibility reason
				strncpy((void *)&Pglobal_data->Prel_List[Next], &in_buf[1], MaxDLLNameLength);
				Pglobal_data->Prel_Sec_Length += MaxDLLNameLength;
				Next++;
				Added = True;
			}
        }
        else if ((in_buf[sl-1] == 'd')||(in_buf[sl-1] == 'D'))
		{
			i=0;
			modulesToDelLen=0;
			while ((in_buf[i] != 'd') && (in_buf[i] != 'D') && (in_buf[i] != '\0'))
			{
				j = 0;
				// read the preloaded number to delete and the clickable state of the button (p-press, u-unpress)
				rc = sscanf(in_buf+i, "%1d%s", &j, buf);
				i++;
				if ( j >= 10 )
					i++;

				// check if it is valid preloaded number and with press state
				if ((rc == 2) && (j >= 1) && (j <= Next) && (in_buf[i] == 'p'))
				{
					j--;
					memcpy(&Pglobal_data->Prel_List[j], &Pglobal_data->Prel_List[j+1],
                       ((Next - j+2) * sizeof(Pglobal_data->Prel_List[0])));
					  Pglobal_data->Prel_Sec_Length -= MaxDLLNameLength;
					  modulesToDelLen++;
					  Deleted = True;
				}
				i++;
			}
			Next = Next - modulesToDelLen;
        }
        else
			continue;
    }

    if ((!Deleted) && (!Added))
	{
		csvh_scr_close (Scr);
		return Menu_Ok;
	}
	// if the user does not want to save changes then exit.
	if (!_csvh_yesno(False, headline, csvh_msg(MSG_IPROUTE_SAVE)))
	{
		if (Pglobal_data->Prel_List != NULL)
			FreeMem(Pglobal_data->Prel_List);

		// No default (empty list)
        Pglobal_data->Prel_List = NULL;
        Pglobal_data->Prel_Sec_Length = 0;
        if (rc = ArConfGetSection(Prel_SecName, (void *)&(Pglobal_data->Prel_List), &(Pglobal_data->Prel_Sec_Length), &Save_on_Init))
			_csvh_err(headline, csvh_msg(ERR_NO_PREL_SEC), rc);
		csvh_scr_close (Scr);
        return Menu_Ok;
	}

	// Ask to insert the startup smart card and authenticate for this update
    if (verify_operator_needed() && (!verify_operator(NULL, MANUAL_PSW, "Pre-Loaded Modules")))
	{
		_csvh_err(headline, csvh_msg(MSG_FAILED_VERIFY_OPERATOR));

		// Not operator, recover from file
        if (Pglobal_data->Prel_List != NULL)
			FreeMem(Pglobal_data->Prel_List);

		// No default (empty list)
		Pglobal_data->Prel_List = NULL;
        Pglobal_data->Prel_Sec_Length = 0;
        if (rc = ArConfGetSection(Prel_SecName, (void *)&(Pglobal_data->Prel_List), &(Pglobal_data->Prel_Sec_Length), &Save_on_Init))
			_csvh_err(headline, csvh_msg(ERR_NO_PREL_SEC), rc);

        csvh_scr_close (Scr);
		return Menu_Ok;
    }

	// Update the configuration file with the updates
    if (rc = ArConfUpdateSection(Prel_SecName, Pglobal_data->Prel_List, Pglobal_data->Prel_Sec_Length, True))
		_csvh_err(headline, csvh_msg(ERR_PREL_UPDATE), rc);
    else if (Added)
		_csvh_warning(headline, csvh_msg(MSG_PREL_RESTART));

	csvh_scr_close (Scr);
    return Menu_Ok;
}


// -------------------------------------------------------------------
//	choice_shutdown
//
//	Routine description:
//		Restart the PrivateServer and return to the first menu
//
//	Arguments:
//		Code - Not used
//		Id - Not used.
//
//	Returns:
//		Menu_Ok (back to menu).
// -------------------------------------------------------------------
static  MENU_ACTION choice_shutdown (int Code, int Id)
{
    int rc;
	char header[] =  "Shutdown PrivateServer";
    struct Global_data* Pglobal_data = GPglobal_data();

    Code += Id; // Just to avoid warnings.
    rc = _csvh_yesno(False, header, csvh_msg(MSG_CONFIRM_OP_SHUTDOWN));
    if ((rc == TIMEOUT_OPTION) || (rc == False))
		return Menu_Refresh;
    if (verify_operator(NULL, MANUAL_PSW, header))
    {
		// winodws is shutting down.. please wait message
		csvh_scr_clr(CSVH_SCR_CURRENT);
		csvh_scr_printf(CSVH_SCR_CURRENT, MSG_HEADER, "Shutdown", header);
		_csvh_scr_printf(CSVH_SCR_CURRENT, "<type=\"roundrect\" name=\"Msg\" width=\"770\" height=\"150\" posx=\"70\" posy=\"150\" locked=\"true\" text=\"Please wait...\" fontsize=\"24\" fontstyle=\"B\" forecolor=\"255, 255, 255\" textalign=\"MiddleLeft\" withbackground=\"false\">");

		// csv_shutdown returned an error
		if (csv_shutdown(NULL))
		{
			csvh_err(ERR_FLG_LOG, ERR_SYSTEM_SHUTDOWN_FAILED);
			if (_csvh_yesno (False, header, csvh_msg(MSG_FORCE_SHUTDOWN)))
			{
				csvh_err(ERR_FLG_LOG, MSG_SHUTDOWN_FORCED);
				Pglobal_data->Shut_down_msg=1;
				DosPostEventSem (Pglobal_data->Msg_EventSem) ;

				raise_sem();	// we don't check return code - cause anyway we continue to exit.
			}
		}
		else
			return Menu_Ok;
    }
	else
		_csvh_err(header, csvh_msg(MSG_FAILED_VERIFY_OPERATOR));

    // Somthing has occurred and we want to return to the Main menu screen (the original menu)
    return Menu_Refresh;
}

// -------------------------------------------------------------------
//	get_out
//
//	Routine description:
//		In case of error this function is called to teminate the servers work
//
//	Arguments:
//		Code - Not used
//		Id - Not used.
//
//	Returns:
//		Menu_Close (close the menu).
// -------------------------------------------------------------------
static  MENU_ACTION get_out (int Code, int Id)
{

    Code += Id; // Just to avoid warnings.

    if (Ckit_Started)
		ckit_end();

    csvh_close_helpers();

	// shutdown the ARCS service
	// turn on the semaphore
	// we don't check return code - cause anyway we continue to exit.
	raise_sem();

    return Menu_Close; // Just to avoid warnings.
}


//---------------------------------------------------------------------
//	choice_init
//
//	Routine description:
//		This function performs initialization of the ARCryptoServer by reading
//		all the necessary information from the INIT, STARTUP and ROOT cards
//
//	Arguments:
//		remove_old - (menu option function "Code" argument)  flag, that says
//		whether to remove the old database
//		Id - Not used.
//
//	Returns:
//		Menu_Ok (back to menu).
//------------------------------------------------------------------------
static MENU_ACTION choice_init ( int remove_old , int Id )
{
	// SVMK is 64-byte Master Keys buffer that contains:
	// 16 bytes - SVMK, 16 bytes - MAC key, 16 bytes - KEK,
	// 16 bytes - backup/restore key. Supported from v4.2

	unsigned char	SVMK	  [MASTER_KEYS_LEN]  = {0},
					SVMK_init [MASTER_KEYS_LEN]  = {0},
					root_name [32]				 = {0},
					psv_name  [32]				 = {0},
					root_cert [5000]			 = {0},
					psv_cert  [5000]			 = {0},
					private_key_val[MAX_KEY_LEN] = {0},
					public_key_val[MAX_KEY_LEN]	 = {0};

	unsigned char	unattended_data[MASTER_KEYS_LEN +1] = {0};
	unsigned char	cureentDBlog[30]={0};

	USER_STRUCT_EX  user_rec;
	x509Details		psv_cert_details;
	VKEY_STRUCT		private_key;

	int				rc = 0,
					rc3 = 0;
	unsigned int	root_cert_len = 5000,
					psv_cert_len = 5000;
	char			header[] = "Init Database";

   //  -------------------------------------------  //
   //  Read all necessary data from the INIT card.  //
   //  -------------------------------------------  //
	memset (&psv_cert_details, 0, sizeof (psv_cert_details));
	memset (&private_key, 0, sizeof(private_key));

	private_key.value.data = private_key_val;
	private_key.value.size = sizeof(private_key_val);

	// here add the master smartcard check function
	if (rc = ckit_wait_for_card (TRUE, MSG_INSERT_MASTER_CARD, header))
		goto RET;

	if(rc = verify_master_smartcard())
		goto RET;

	if (rc = ckit_wait_for_card (FALSE, MSG_REMOVE_CARD, header))
		goto RET;

	// Wait for the user to insert the Init smart card
	if (rc = ckit_wait_for_card (TRUE, MSG_INSERT_INIT_CARD, header))
		goto RET;

	// open session.
	if (rc = ckit_on ())
		goto RET;

	// Verify it is the Init smart card by checking the card label
	if (rc = ckit_verify_card_type (ARSERVER_INIT_LABEL, header))
		goto RET;

	// Read the PrivateServer certificate details
	if (rc = ckit_read (TRUE, ARSERVER_INIT_CERT_DETAILS, &psv_cert_details, sizeof(psv_cert_details)))
		goto RET;

	// Ask the user for the init password
	if (rc = ckit_login (psv_cert_details.ID, header))
		goto RET;

	// Read from the card buffer of 64 bytes length. This buffer contains 4 Master keys:
	// SVMK, MAC, KEK, Backup/Restore
	if (rc = ckit_read (TRUE, ARSERVER_SVMK_FIRST_HALF, SVMK_init, sizeof(SVMK_init)))
		goto RET;

	// Read the first user struct that hold the first user details
	if (rc = ckit_read (TRUE, ARSERVER_FIRST_USER, &user_rec, sizeof(user_rec)))
		goto RET;

	// Update the PrivateServer name
	strcpy((char*)psv_name, (char*)psv_cert_details.ID);

	// close session.
	if (rc = ckit_off ())
		goto RET;

	// Wait until the user remove the Init card
	if (rc = ckit_wait_for_card (FALSE, MSG_REMOVE_CARD, header))
		goto RET;

	// ----------------------------------------------------------- //
    // Writing 1/2 SVMK to the Tamper memory and read StartUp card //
	// ----------------------------------------------------------- //

	if (rc = cs_set_unatt_data (unattended_data))
		goto RET;

	if (rc = SVMK_from_startup_card (SVMK, SVMK_init))
		goto RET;

	// ----------------------------------------------------------- //
	// Perform database initialization                             //
	// ----------------------------------------------------------- //

	// Insert the first half of the SVMK (init data) to the tamper
	rc = cs_put_SVMK (SVMK_init);
	if(rc)
	{
		_csvh_err(header, csvh_msg(ERR_WORK_WITH_TAMPER), rc);
		csvh_err(ERR_FLG_LOG, ERR_WORK_WITH_TAMPER, rc);
		goto RET;
	}

	// Wait for the user to insert the Root smart card
	if (rc = ckit_wait_for_card (TRUE, MSG_INSERT_ROOT_CARD, header))
		goto RET;

	// open session.
	if (rc = ckit_on ())
		goto RET;

	// Verify its the Root smart card by checking the card label
	if (rc = ckit_verify_card_type (ARSERVER_ROOT_LABEL, header))
		goto RET;

	// Ask the user for the root password
	if (rc = ckit_login ((unsigned char*)"psv", header))
		goto RET;

	// generate RSA 2048 private/public key internally, they will serve as the server keys
	if (rc = ckit_generate_RSA_priv_pub_key (&private_key, public_key_val))
		goto RET;

	// Get the root certificate and create and sign the PrivateServer certificate
	if (rc = ckit_get_root_psv_info (public_key_val, private_key.exp, private_key.explen, &psv_cert_details, psv_cert, &psv_cert_len, root_name, root_cert, &root_cert_len))
		goto RET;

	// close session.
	if (rc = ckit_off ())
		goto RET;

	// Wait until the user remove the Root smart card
	if (rc = ckit_wait_for_card (FALSE, MSG_REMOVE_CARD, header))
		goto RET;

	// Initialize the database
	if (rc3 = db_init (SVMK,
					   &user_rec,
					   (char*)psv_name,
					   psv_cert,
					   psv_cert_len,
					   (char*)root_name,
					   root_cert,
					   root_cert_len,
					   &private_key,
					   remove_old))
	{
		rc = -1;
	    goto RET;
	}

	// ----------------------------------------------------------- //
	// Check tamper memory loaded with 1/2 SVMK                    //
	// ----------------------------------------------------------- //
	if (verify_there_was_no_tamper())
		rc = -1;

RET:
    memset (SVMK,      0, sizeof (SVMK));          // Clear local copy
    memset (SVMK_init, 0, sizeof (SVMK_init));     // Clear local copy

	if (rc3 == CSV_RANDOM_IS_NOT_OK)
	{
        csvh_err(ERR_FLG_LOG,BAD_GET_RANDOM,rc3,0);
		// server should be shutdown if there is an error with the random seed
		csv_shutdown(NULL);
		return -1;
	}

	if (!rc)
	{
		// We will reach this code only if the function ended successfully
		set_dbVersion(0);
		SetCurrentDBlogFile(cureentDBlog, sizeof(cureentDBlog));

		// free the menu mutex, start the server and go to the next menu
		rc = disable_init_options();
	}

	if (rc == TIMEOUT_OPTION)
	{
		csvh_scr_clr(CSVH_SCR_CURRENT);
		screen_saver(1, 1);
	}

    if (rc)
	{
		ckit_off ();
		return Menu_Refresh;
	}

	if(remove_old)
	{
		// ----------------------------------------------------------- //
		// Stop SNMP service and reset all parameters in registry	   //
		// ----------------------------------------------------------- //
		SNMP_init();

		// ----------------------------------------------------------- //
		// Clear syslog parameters in registry	  					   //
		// ----------------------------------------------------------- //
		syslog_configure_internal(0, "");

		// ----------------------------------------------------------- //
		// Reset NTP server											   //
		// ----------------------------------------------------------- //
		NTP_init();
	}

    return Menu_Ok;

} // choice_init


//-------------------------------------------------------------------------
//	choice_startup
//
//	Routine description:
//		this function performs the regular startup of the ARCryptoServer
//
//  Arguments:
//		both ignored
//
//  Returns:
//		Menu_Ok (back to menu).
//-------------------------------------------------------------------------
static  MENU_ACTION  choice_startup ( int Code, int Id )

{
	// SVMK is 64-byte Master Keys buffer that contains:
	// 16 bytes - SVMK, 16 bytes - MAC key, 16 bytes - KEK,
	// 16 bytes - backup/restore key. Supported from v4.2
    unsigned char   SVMK		[MASTER_KEYS_LEN]   = {0};
    unsigned char   SVMK_rest	[MASTER_KEYS_LEN]	= {0};
	int rc = 0, rc1 = 0, rc2 = 0, rc3 = 0, rc4 = 0;

	if ( (rc1 = cs_get_SVMK (SVMK_rest))      || (rc2 = SVMK_from_startup_card (SVMK, SVMK_rest)) ||
		 (rc3 = verify_there_was_no_tamper()) || (rc4 = db_start (SVMK)) )
		rc = -1;

	if (!rc)
		rc = disable_init_options();

    memset (SVMK,      0, sizeof (SVMK));        // Clear local copy
    memset (SVMK_rest, 0, sizeof (SVMK_rest));   // Clear local copy

	// If one of the function returned timeout activate screen saver
	if ((rc == TIMEOUT_OPTION) || (rc1 == TIMEOUT_OPTION) || (rc2 == TIMEOUT_OPTION) ||
		(rc3 == TIMEOUT_OPTION) || (rc4 == TIMEOUT_OPTION))
	{
		csvh_scr_clr(CSVH_SCR_CURRENT);
		screen_saver(1,1);
	}

	if (rc)
		return Menu_Refresh;

    return Menu_Ok;
}

// -------------------------------------------------------------------------
//  choice_rebuild
//
//  Routine description:
//             this function rebuilds the databse files
//
//  Arguments:
//       both ignored
//
//  Returns:
//       Menu_Ok (back to menu).
// -------------------------------------------------------------------------
static  MENU_ACTION  choice_rebuild ( int Code, int Id )
{
	int rc, rc2=0, Scr, i=0;
	char data[1000] = {0};

	Code += Id;

	Scr = csvh_scr_open();
	csvh_scr_set(Scr);

	// print header
	csvh_scr_printf (CSVH_SCR_CURRENT, MSG_HEADER, "rebuildDB", "Rebuild Database");

	// print wait to rebuild
	rc2 = sprintf(data, "%s\n", csvh_msg(MSG_WAIT_REBUILD));
	if (rc2 > 0)
		i += rc2;
	_csvh_scr_printf (CSVH_SCR_CURRENT, "<type=\"roundrect\" name=\"Msg\" width=\"670\" height=\"250\" posx=\"55\" posy=\"155\" locked=\"true\" text=\"%s\" textalign=\"TopLeft\" fontsize=\"22\" forecolor=\"14,96,141\" backcolor=\"White\" >", data);

	// rebuild users db
	rc = csv_rebuild_users_db (USER_DB_NAME);
	rc2 = sprintf(data+i, "Rebuilding %s file - %s \n", "users", (rc == 0)? "Succeeded" : "Failed");
	if (rc2 > 0)
		i += rc2;
	_csvh_scr_printf (CSVH_SCR_CURRENT, "<type=\"update\" name=\"Msg\" text=\"%s\" >", data);

	// rebuild keys db
	rc = csv_rebuild_keys_db (KEY_DB_NAME);
	rc2 = sprintf(data+i, "Rebuilding %s file - %s \n", "keys", (rc == 0)? "Succeeded" : "Failed");
	if (rc2 > 0)
		i += rc2;
	_csvh_scr_printf (CSVH_SCR_CURRENT, "<type=\"update\" name=\"Msg\" text=\"%s\" >", data);

	// rebuild keys owners
	rc = csv_rebuild_userlist_db (OWNERL_DB_NAME);
	rc2 = sprintf(data+i, "Rebuilding %s file - %s \n", "key_owners", (rc == 0)? "Succeeded" : "Failed");
	if (rc2 > 0)
		i += rc2;
	_csvh_scr_printf (CSVH_SCR_CURRENT, "<type=\"update\" name=\"Msg\" text=\"%s\" >", data);

	// rebuild key users
	rc = csv_rebuild_userlist_db (USERL_DB_NAME);
	rc2 = sprintf(data+i, "Rebuilding %s file - %s \n", "key_users", (rc == 0)? "Succeeded" : "Failed");
	if (rc2 > 0)
		i += rc2;
	_csvh_scr_printf (CSVH_SCR_CURRENT, "<type=\"update\" name=\"Msg\" text=\"%s\" >", data);

	// rebuild userext
	rc = csv_rebuild_userext(USEREXT_DB_NAME);
	sprintf(data+i, "Rebuilding %s file - %s \n", "userext", (rc == 0)? "Succeeded" : "Failed");
	_csvh_scr_printf (CSVH_SCR_CURRENT, "<type=\"update\" name=\"Msg\" text=\"%s\" >", data);

	_csvh_scr_printf (CSVH_SCR_CURRENT, "<type=\"gelbutton\" name=\"OK\" width=\"85\" height=\"85\" posx=\"690\" posy=\"417\"  image=\"back\" imagealign=\"Center\" imagekey=\"O\" >");
	rc = csvh_kbd_key_timeout (CSV_FLG_DEFAULT, KBD_TIMEOUT_MILIS);

	csvh_scr_close(Scr);
	if (rc == TIMEOUT_OPTION)
		screen_saver(1,1);

	return Menu_Ok;
}

// -------------------------------------------------------------------------
//  choice_run
//
//  Routine description:
//		this is the menu option that start the server, and show the main server console
//		when this option is selected it release the DosPostEventSem and let the main thread run
//
//  Arguments:
//       both ignored
//
//  Returns:
//       Menu_Close (close the menu).
// -------------------------------------------------------------------------
static  MENU_ACTION  choice_run ( int Code, int Id )
{
    Code += Id; // Just to avoid warnings.

    csvh_menu_default (Main_Menu, Back_Option_Id_M, 15);

    csvh_menu_set_main(Main_Menu);

	csvh_menu_enable (Config_Menu, SetPass_Option_Id);

    DosPostEventSem(Init_Event); // let the main thread run.
    return Menu_Close;     // close the main menu (status screen is below)
}


// -------------------------------------------------------------------------
// Disables in the Menu
// -------------------------------------------------------------------------
static  MENU_ACTION  choice_diag ( int Code, int Id )
{
    Code += Id; // Just to avoid warnings.

    csvh_err (ERR_FLG_SCREEN, ERR_LOG_NO_MODE);
    return Menu_Ok;
}


#ifndef NON_FIPS
// -------------------------------------------------------------------------
//	choice_reset_tamper
//
//  Routine description:
//		this function reset the tampering value that is stored in the config file
//		not before it reads both the init and startup cards.
//
//  Arguments:
//      both ignored
//
//  Returns:
//	    Menu_Ok (back to menu).
// -------------------------------------------------------------------------
static  MENU_ACTION  choice_reset_tamper ( int Code, int Id )
{
	// SVMK is 64-byte Master Keys buffer that contains:
	// 16 bytes - SVMK, 16 bytes - MAC key, 16 bytes - KEK,
	// 16 bytes - backup/restore key. Supported from v4.2
    int				rc = 0;
	int				save_on_init = TRUE;

	char			header[] = "Reset Tamper";
	unsigned char	SVMK	  [MASTER_KEYS_LEN] = {0},
					SVMK_init [MASTER_KEYS_LEN] = {0};

	x509Details		psv_cert_details;

	Id;  //  Just to avoid warnings.

	memset(&psv_cert_details, 0, sizeof(psv_cert_details));

	//  -------------------------------------------  //
    //  Read all necessary data from the INIT card.  //
    //  -------------------------------------------  //

	// Wait for the user to insert the Init smart card
	if (rc = ckit_wait_for_card (TRUE, MSG_INSERT_INIT_CARD, header))
		goto RET;

	// Verify its the Init smart card by checking the card label
	if (rc = ckit_on ())
		goto RET;

	// Verify its the Init smart card by checking the card label
	if (rc = ckit_verify_card_type (ARSERVER_INIT_LABEL, header))
		goto RET;

	// Read the PrivateServer certificate details
	if (rc = ckit_read (TRUE, ARSERVER_INIT_CERT_DETAILS, &psv_cert_details, sizeof(psv_cert_details)))
		goto RET;

	// Get the init x509 certificate details
	if (rc = ckit_login (psv_cert_details.ID, header))
		goto RET;

	// Read from the card buffer of 64 bytes length. This buffer contains 4 Master keys:
	// SVMK, MAC, KEK, Backup/Restore
	if (rc = ckit_read (TRUE, ARSERVER_SVMK_FIRST_HALF, SVMK_init, sizeof(SVMK_init)))
		goto RET;

	// close session.
	if (rc = ckit_off ())
		goto RET;

	// Wait until the user remove the Init card
	if (rc = ckit_wait_for_card (FALSE, MSG_REMOVE_CARD, header))
		goto RET;


	// ----------------------------------------------------------- //
    // Writing 1/2 SVMK to the Tamper memory and read StartUp card //
	// ----------------------------------------------------------- //
	if(rc == 0)
	{
		unsigned char unattended_data[MASTER_KEYS_LEN +1] = {0};
		if (rc = cs_set_unatt_data (unattended_data))
			goto RET;

		if (rc = SVMK_from_startup_card (SVMK, SVMK_init))
			goto RET;

		// ----------------------------------------------------------- //
		// Perform database initialization                             //
		// ----------------------------------------------------------- //
		rc = cs_put_SVMK (SVMK_init);
		if(rc)
		{
			csvh_err(ERR_FLG_LOG, ERR_WORK_WITH_TAMPER, rc);
			_csvh_err(header, csvh_msg(ERR_WORK_WITH_TAMPER), rc);
			goto RET;
		}

		// If setting the SVMK_init succeed start the database
		rc = db_start (SVMK);
	}

RET:
	memset (SVMK,      0, sizeof (SVMK));          // Clear local copy
	memset (SVMK_init, 0, sizeof (SVMK_init));     // Clear local copy
	if (rc)
		ckit_off ();

	if (!rc)
		rc = disable_init_options();

	send_snmp_trap(PSV_SNMP_TAMPER_RESET);

	if (rc == TIMEOUT_OPTION)
	{
		csvh_scr_clr(CSVH_SCR_CURRENT);
		screen_saver(1,1);
	}

	if (rc)
		return Menu_Refresh;
    return Menu_Ok;
} // choice_reset_tamper

#endif

// titles of newly extended modules
static char		titles[MAX_EXT_MOD][300]={0};


// -------------------------------------------------------------------------
//	disable_init_options
//
//  Routine description:
//		load all the preloaded modules to the arcs space memory, clear the menu options of the startup menu, and
//		show the new menu, one step before the server is up
//
//  Arguments:
//      none
//
//  Returns:
//	    none
// -------------------------------------------------------------------------
static int disable_init_options ( void )
{
    int         j, l, Rc, errBufInd=0, rc=0;
    int         Load_Ok = True;
    int         Save_on_Init = True;
	char        DllName[MaxDLLNameLength+1], errBuf[1000] = {0};
	int			i;
	struct Global_data* Pglobal_data = GPglobal_data();

	// Enables the configuration menu item
    csvh_menu_enable (Startup_Menu, Config_Option_Id);

    // Pre-load modules, giving them the chance to change the menu.
    // Get current configuration
    Pglobal_data->Prel_List = NULL;

	// No default (empty list)
    Pglobal_data->Prel_Sec_Length = 0;
    if (Rc = ArConfGetSection(Prel_SecName, (void *)&(Pglobal_data->Prel_List), &(Pglobal_data->Prel_Sec_Length), &Save_on_Init))
	{
        rc = _csvh_err ("Startup Menu", csvh_msg(ERR_NO_PREL_SEC), Rc);
        Load_Ok = False;
    }

	// Load all the preloaded dll modules to the arcs application memory space
    l = Pglobal_data->Prel_Sec_Length / sizeof(Pglobal_data->Prel_List[0]);
    DllName[MaxDLLNameLength] = '\0';
    for (j = 0; j < l; j++)
	{
        strncpy(DllName, Pglobal_data->Prel_List[j], MaxDLLNameLength);

		if (!csvh_dll_load(DllName, False))
		{
			 if (errBufInd > 0)
			 {
				 sprintf(errBuf + errBufInd, "\n");
				 errBufInd++;
			 }
			 sprintf(errBuf + errBufInd, "Error loading moudle %s. ", DllName);
			 errBufInd = strlen(errBuf);
			 Load_Ok = False;
		}
    }

	// Load SDKMNG module as if it was preloaded module
	// Module load can fail if no module, no license or no .NET framework.
	// There is nothing to do, in this case this module just won't be accessible.
	csvh_dll_load("sdkmng", False);

	// If all the modules were loaded properly, disable all the previous menu items
	// and show the new server menu items (start services, configuration..)
    if (Load_Ok)
	{
		// Disable init, startup, rebuild menu items
        csvh_menu_disable (Startup_Menu, Init_Option_Id);
        csvh_menu_disable (Startup_Menu, Startup_Option_Id);
        csvh_menu_disable (Startup_Menu, Rebuild_Option_Id);
		// The next line was removed in order to disable the option of manual entry of the SVMK.
        // csvh_menu_disable (Startup_Menu, Manual_Option_Id);

#ifndef NON_FIPS
		csvh_menu_disable (Startup_Menu, reset_tamper_Option_Id);
#endif
		// The ExtendedX_Option will be relevant only if the
		// extfuncX.dll exists.
		for (i=0;i<MAX_EXT_MOD;i++)
		{
			char DllName[30];
			sprintf(DllName,"extfunc%d",i);
			if (is_extfunc_dll_exist(DllName,&(is_extfunc_dll_loaded[i]), &(phMod[i]),titles[i]))
				csvh_menu_disable (Startup_Menu, Extended_Option_Id[i]);
		}

		// Enable the new menu item of starting the server main console view
        csvh_menu_enable (Startup_Menu, Run_Option_Id);
		
		// Run with short timeout
		csvh_menu_default (Startup_Menu, Run_Option_Id, 5);
    }
    else
	{
		// If timeout accored return error before present the screen massage
		if (rc == TIMEOUT_OPTION)
			return rc;
		rc = _csvh_err("Startup Menu", errBuf);

		// Return that error occured
		if (rc != TIMEOUT_OPTION)
			rc = -1;
	}
	return rc;
}

// ------------------------------------------------------------------------- */
//	choice_extended
//
//  Routine description:
//		this function adds an entry to the startup menu as an infrastructure
//		for futur modules that will require interaction with the console.
//
//  Arguments:
//		index - the extended module chosen index
//
//    Returns:
//        Menu_Ok - OK, rc != 0 - error
// -------------------------------------------------------------------------
static int choice_extended (int index)
{
	int rc = CSV_OK;

	CSV_EXTFUNC extfunc=NULL;

	rc = get_function_add((void **)&extfunc, &(phMod[index]), "csv_extfunc");
	if (rc)
	{
		// If we fail, we write an error to the console and to the log
		_csvh_err("Extended Module", csvh_msg(MSG_EXTFUNC_UNAVAILABLE));
		return rc;
	}

	// If we are here, means that we succeeded to get the pointer to the function
	rc = extfunc();
	if (rc)
		return rc;
	else
		return Menu_Ok;
}


typedef MENU_ACTION (*CSV_INT_CHOICE)(int Code, int Id);

CSV_INT_CHOICE ChoiceFuncArr[MAX_EXT_MOD]={0};

// all following functions stands for extended modules to be operated from console
static  MENU_ACTION choice_extended0 ( int Code, int Id )
{
	return (MENU_ACTION) choice_extended(0);
}
static  MENU_ACTION choice_extended1 ( int Code, int Id )
{
	return (MENU_ACTION) choice_extended(1);
}
static  MENU_ACTION choice_extended2 ( int Code, int Id )
{
	return (MENU_ACTION) choice_extended(2);
}
static  MENU_ACTION choice_extended3 ( int Code, int Id )
{
	return (MENU_ACTION) choice_extended(3);
}
static  MENU_ACTION choice_extended4 ( int Code, int Id )
{
	return (MENU_ACTION) choice_extended(4);
}
static  MENU_ACTION choice_extended5 ( int Code, int Id )
{
	return (MENU_ACTION) choice_extended(5);
}
static  MENU_ACTION choice_extended6 ( int Code, int Id )
{
	return (MENU_ACTION) choice_extended(6);
}
static  MENU_ACTION choice_extended7 ( int Code, int Id )
{
	return (MENU_ACTION) choice_extended(7);
}
static  MENU_ACTION choice_extended8 ( int Code, int Id )
{
	return (MENU_ACTION) choice_extended(8);
}
static  MENU_ACTION choice_extended9 ( int Code, int Id )
{
	return (MENU_ACTION) choice_extended(9);
}


void InitChoiceArrFunc()
{
	ChoiceFuncArr[0]= choice_extended0;
	ChoiceFuncArr[1]= choice_extended1;
	ChoiceFuncArr[2]= choice_extended2;
	ChoiceFuncArr[3]= choice_extended3;
	ChoiceFuncArr[4]= choice_extended4;
	ChoiceFuncArr[5]= choice_extended5;
	ChoiceFuncArr[6]= choice_extended6;
	ChoiceFuncArr[7]= choice_extended7;
	ChoiceFuncArr[8]= choice_extended8;
	ChoiceFuncArr[9]= choice_extended9;
}


// -------------------------------------------------------------------------
//
//  Routine description:
//      Handle initialization menus
//
//  Notes:
//      operation modes Update and Diagnoseare not implemented
//      in this stage
//
//  Arguments:
//      none
//
//  Returns:
//      none
// -------------------------------------------------------------------------
void csv_create_menus ( void )
{
	int i;

	Startup_Menu = (struct Menu *)csvh_menu_Ncreate(MSG_STARTMENU_HEADER, 0, 20);
    Main_Menu    = (struct Menu *)csvh_menu_Ncreate(MSG_MAIN_MENU_HEADER, 0, 20);
    Config_Menu  = (struct Menu *)csvh_menu_Ncreate(MSG_CONFIGURE_HEADER, 0, 20);
    if (Startup_Menu == NULL)
		csvh_err (ERR_FLG_DEFAULT, ERR_START_MENU_1);
    else if (Main_Menu == NULL)
		csvh_err (ERR_FLG_DEFAULT, ERR_MAIN_MENU_1);
    else if (Config_Menu == NULL)
		csvh_err (ERR_FLG_DEFAULT, ERR_CONFIG_MENU_1);
    else
	{
        //																     Code, Enabled,      Def,   Func,           Sub_M,		Pos  DynamicPos
        Startup_Option_Id =
			csvh_menu_Nadd_item  (Startup_Menu, MSG_STARTMENU_STARTUP,
									  csvh_msg(MSG_STARTMENU_START_TXT),      0, Ckit_Started, True,  choice_startup, NULL,			0,	  1);
        Init_Option_Id =
        csvh_menu_Nadd_item  (Startup_Menu, MSG_STARTMENU_INIT, NULL ,     True, Ckit_Started, False, choice_init,    NULL,			0,	  1);
        Rebuild_Option_Id =
        csvh_menu_Nadd_item  (Startup_Menu, MSG_STARTMENU_REBUILD, NULL,      0, True,		 False, choice_rebuild, NULL,			0,	  1);
		Run_Option_Id =
        csvh_menu_Nadd_item  (Startup_Menu, MSG_STARTMENU_RUN, NULL,  0, False,      False, choice_run,     NULL, 0,	  1);
        Config_Option_Id =
        csvh_menu_Nadd_item  (Startup_Menu, MSG_STARTMENU_CONF, NULL,         0, False,        False, NULL,           Config_Menu,	0,	  1);

#ifndef NON_FIPS
		reset_tamper_Option_Id =
        csvh_menu_Nadd_item  (Startup_Menu, MSG_STARTMENU_RST_TAMPER, NULL,   0, Ckit_Started, False, choice_reset_tamper, NULL,	0,	  1);
#endif

		// The Extended_Option will be written to the console startup menu only if the
		// extfunc.dll exist.
		InitChoiceArrFunc();

		for (i=0;i<MAX_EXT_MOD;i++)
		{
			char DllName[50];
			sprintf(DllName,"extfunc%d",i);
			if (is_extfunc_dll_exist(DllName, &(is_extfunc_dll_loaded[i]), &(phMod[i]),titles[i]))
			{
				Extended_Option_Id[i] =
					csvh_menu_add_item  (Startup_Menu, titles[i], NULL,  0, Ckit_Started, True, ChoiceFuncArr[i],    NULL, 0,	  1);
			}
		}

        Back_Option_Id =
        csvh_menu_Nadd_item  (Startup_Menu, MSG_STARTMENU_BACK, NULL,    0, True,       False, get_out,        NULL, 0,	  0);

        // Main Menu

        csvh_menu_Nadd_item  (Main_Menu, MSG_STARTMENU_CONF, NULL,  0, True, False, NULL,            Config_Menu, 0,	  1);

		Lock_Option_Id =
        csvh_menu_Nadd_item  (Main_Menu, MSG_STARTMENU_LOCK, NULL,  0, True, False, choice_lock,           NULL,			0,	  1);

        Shutd_Option_Id =
        csvh_menu_Nadd_item  (Main_Menu, MSG_MAIN_MENU_SHUTDWON, NULL, 0, True, False, choice_shutdown, NULL, 0,	  1);
        Back_Option_Id_M =
        csvh_menu_Nadd_item  (Main_Menu, MSG_MAIN_MENU_BACK, NULL,  0, True, True,  NULL,            NULL, 0,	  0);

        csvh_menu_Nadd_item  (Config_Menu, MSG_CONFIGMENU_PREL, NULL, 0, True, False, choice_prel,    NULL, 0,	  1);
        csvh_menu_Nadd_item  (Config_Menu, MSG_CONFIGMENU_BACK, NULL,  0, True, True,  NULL,           NULL, 0,	  0);

		SetPass_Option_Id =
		csvh_menu_Nadd_item  (Config_Menu, MSG_MAIN_MENU_UNATTEN, NULL,    0, False, False, choice_passwd,  NULL, 0,	  1);

		csvh_func_set_lock_menu(choice_lock);

	csvh_menu_default (Startup_Menu, Startup_Option_Id, 20);
        csvh_menu_set_main(Startup_Menu);
        csvh_menu_post    (Startup_Menu);
    }
}


// File on SmartCard contains 64-byte Master Keys buffer.
// In Op_SVMK parameter only first 16-bytes are saved.
// Read all Master Keys buffer from SC and compare only first 16 bytes
int verify_operator(char *pwd, int pwd_mode, char * headline)
{
	unsigned char Svmk[MASTER_KEYS_LEN] = {0};

	return verify_operator_ext(pwd, pwd_mode, Svmk, headline);

}


// File on SmartCard contains 64-byte Master Keys buffer.
// In Op_SVMK parameter only first 16-bytes are saved.
// Read all Master Keys buffer from SC and compare only first 16 bytes
int verify_operator_ext(char *pwd, int pwd_mode, unsigned char Svmk[MASTER_KEYS_LEN], char *headline)
{
	int rc;

	unsigned char *Op_SVMK = GetOp_SVMK();

	rc =  (!(read_startup_card(Svmk, headline)) && (memcmp(Op_SVMK, Svmk, SVMK_LENGTH) == 0));

	if (!rc)
	{
		csvh_err(ERR_FLG_LOG, MSG_FAILED_VERIFY_OPERATOR);
	}

	return rc;

}

int verify_operator_needed()
{
	int rc = 1;
	unsigned char   unatt_data  [MASTER_KEYS_LEN+1] = {0};

	if (AFTER_startup)
		return rc;

	rc = cs_get_unatt_data (unatt_data);
	if (!rc && !unatt_data[0])
		return 0; 
	
	return 1;
}

/* ======================== LOCAL HELPER ROUTINES ========================= */


/*****************************************************************************
*								read_startup_card
*							   -------------------
*  This routine reads 1/2 of Master Keys buffer (64 bytes)
*  from the STARTUP smartcard
*
*  Arguments:
*		Svmk
*            buffer for SVMK to be readed
*       pwd
*            card access pw, or NULL (operator types the pw)
*
*  Returns:
*       0 - OK
*      -1 - error

******************************************************************************/
static int read_startup_card ( unsigned char Svmk[MASTER_KEYS_LEN], char * headline)
{
    int rc = 0, Rc = 0, rc2 = 0;
	struct Global_data* Pglobal_data = GPglobal_data();

	if (AFTER_startup)
	{
       if (rc = ckit_start())
		   csvh_err(ERR_FLG_LOG, CSV_BAD_HL_START, rc, 0);
    }

    if (AFTER_startup)
	{
        if (!CSAFE_ok)
			return 0;   // enable CS-free operation
        if (rc = DosRequestMutexSem (Pglobal_data->CSafe_MutexSem, 2000))
		{
            csvh_err       (ERR_FLG_LOG, MSG_CSAFE_MUTEX_F, rc);
			if (_csvh_err       (headline, csvh_msg(MSG_CSAFE_MUTEX_F), rc) == TIMEOUT_OPTION)
				return TIMEOUT_OPTION;
            return -1;
        }
    }

    if (rc = ckit_wait_for_card (TRUE, MSG_INSERT_STARTUP_CARD, headline))
	{
		Rc = -1;
		goto END;
	}

	// open session
	if (rc = ckit_on ())
		goto END;

    if (rc = ckit_verify_card_type (ARSERVER_STARTUP_LABEL, headline))
	{
		Rc = -1;
		goto END;
	}

	if (rc = ckit_login((unsigned char*)"psv", headline) )
	{
		Rc = -1;
		goto END;
	}

	// If read SVMK failed return -2. Read from new file that contains buffer of 64
	// bytes length. This buffer contains 4 Master keys: SVMK, MAC, KEK, Backup/Restore
	Rc = ckit_read(FALSE, ARSERVER_SVMK_SECOND_HALF, Svmk, MASTER_KEYS_LEN);
	if(Rc)
	{
		Rc = -3;
	}

	// close session.
	if (rc = ckit_off ())
		goto END;

    if (ckit_wait_for_card (FALSE, MSG_REMOVE_CARD, headline))
		Rc = -1;

END:
	if (rc)
		ckit_off();
	if (rc == TIMEOUT_OPTION)
		Rc = TIMEOUT_OPTION;
	if (AFTER_startup)
	{
		ckit_end();
		DosReleaseMutexSem(Pglobal_data->CSafe_MutexSem);
    }

    return Rc;
}

/***************************************************************************
*							SVMK_from_startup_card
*						   ------------------------
*  This routine reads 1/2 of Master Keys buffer (64 bytes)
*  from the STARTUP smartcard, save it for later operator verification
*  and XOR it with the other part to create the PrivateServer SVMK.
*
*    Arguments:
*        SVMK - OUT
*            buffer for SVMK to be readed
*        SVMK_rest
*            the rest of SVMK to be XORed with the part readed from the
*            STARTUP card
*        user_id
*            user ID of the STARTUP card (to be checked (may be NULL)
*
*    Returns:
*        0 - OK
*       -1 - error

*****************************************************************************/
static int SVMK_from_startup_card ( unsigned char Svmk[MASTER_KEYS_LEN] ,
									unsigned char SVMK_rest[MASTER_KEYS_LEN])

{
	int				rc								= CSV_OK;
	unsigned char  *Op_SVMK							= GetOp_SVMK();
	unsigned char   unatt_data  [MASTER_KEYS_LEN+1] = {0};
	char headline[] = "Start PrivateServer";

	rc = cs_get_unatt_data (unatt_data);

	if (rc)
	{
		csvh_err (ERR_FLG_LOG, ERR_WORK_WITH_TAMPER, rc);
		if (rc == TIMEOUT_OPTION || _csvh_err (headline,  csvh_msg(MSG_USING_UNATTENDED), rc) == TIMEOUT_OPTION)
			return TIMEOUT_OPTION;
		return -1;
	}

	// Check if its unattended mode
	if (unatt_data[0] == 1)
	{
		csvh_err       (ERR_FLG_LOG,      MSG_USING_UNATTENDED);
		memcpy(Svmk, unatt_data +1, MASTER_KEYS_LEN);
	}
    else if (rc = read_startup_card(Svmk, headline))
	{
		if (rc == TIMEOUT_OPTION)
			return TIMEOUT_OPTION;

		if(rc == -3)
			if (_csvh_err (headline, csvh_msg(STARTUP_READ_ERROR)) == TIMEOUT_OPTION)
				return TIMEOUT_OPTION;

		return -1;
	}

    memcpy(Op_SVMK, Svmk, SVMK_LENGTH);
    XOR_SVMK (Svmk, SVMK_rest);

    return 0;
}

// -------------------------------------------------------------------------
//	  XOR_SVMK
//
//    Routine description:
//        this function builds Master Keys buffer (64 bytes)
//  	  from two parts by using XOR
//
//    Arguments:
//        dst
//            half-of-SVMK uses as a destination too
//        src
//            another half-of-SVMK
//
//    Returns:
//        none
// -------------------------------------------------------------------------
static  void    XOR_SVMK ( unsigned char dst[MASTER_KEYS_LEN] , unsigned char src[MASTER_KEYS_LEN] )
{
    int i;
    for ( i = 0 ; i < MASTER_KEYS_LEN ; i++ )
        dst[i] ^= src[i];
}

// -------------------------------------------------------------------------
//	  convert_SVMK
//
//    Routine description:
//        this function translates the visible presentation of half-of-SVMK
//        (32 hexadecimal characters) into 64-bytes buffer
//
//    Arguments:
//        dst
//            64-bytes destination buffer
//        src
//            32 hexadecimal characters
//
//    Returns:
//        none
// -------------------------------------------------------------------------
static  void    convert_SVMK ( unsigned char dst[MASTER_KEYS_LEN] , char * src )

{
    int i;
    for ( i = 0 ; i < MASTER_KEYS_LEN ; i++ )
        dst[i] = (ascii_hex_to_bin (src[2 * i]) << 4) |
                                            ascii_hex_to_bin (src[2 * i + 1]);
}

// -------------------------------------------------------------------------
//	  ascii_hex_to_bin
//
//    Routine description:
//        this function converts hexadecimal ASCII character to number
//
//    Arguments:
//        src
//            hexadecimal ASCII character
//
//    Returns:
//        number (one hexadecimal digit)
// -------------------------------------------------------------------------
static  unsigned char   ascii_hex_to_bin ( char src )
{
    return (isdigit (src) ? (src - '0') : (toupper (src) - 'A' + '\x0A'));
}


//-----------------------------------------------------------------*
//	 verify_there_was_no_tamper
//
//	 This function gets SVMK part from the Tamper Device. In case
//	 everithing is OK and no tamper was detected this function
//	 returns CSV_OK.
//
//	 Otherwise this function displays message to the console and
//	 writes it to the PrivateServer Log.

//	The message that is displayed, suggests the user to choose "reset tamper
//	value" menu option before he can restart the CSV.
//
//	NOTE: That out of all the bizar reasons (the device is not connected, failed
//	to read the SVMK part from the  tamper etc.) that can cause this function
//	to fail, there are 2 main reasons:
//
//	1. The CSV was really opened and the tamper memory was reseted
//	   to be 0xFF in each byte.
//	2. The SVMK was replaced by a new one. (when The user starts working with
//	   his own keys rather than AR's keys).
//-----------------------------------------------------------------

static int verify_there_was_no_tamper ()
{

	int				rc = CSV_OK;

// In case of non FIPS version of the PrivateServer
// there is no tamper check.
#ifndef NON_FIPS

	// Data on tamper contains 64-byte Master Keys buffer:
	// 16 bytes - SVMK, 16 bytes - MAC key, 16 bytes - KEK,
	// 16 bytes - backup/restore key. Supported from v4.2
	unsigned char SVMK_FROM_TAMPER[MASTER_KEYS_LEN] = {0};
	unsigned char TAMPER_EVENT[MASTER_KEYS_LEN]     = {0};

	memset(TAMPER_EVENT,0xFF,sizeof(TAMPER_EVENT));

	// Following Block of the code reads Tamper memory, that must
	// contain Part of the Master KEys buffer (64 bytes).
	// In case Tamper was triggered, the Master Keys buffer
	// contains 0xFF in each byte.
	if( rc = psv4_read_tamper_mem(SVMK_MEM_OFFSET, MASTER_KEYS_LEN, SVMK_FROM_TAMPER))
	{
        csvh_err       (ERR_FLG_LOG,ERR_WORK_WITH_TAMPER, rc);
		if (_csvh_err       ("Tamper Event", csvh_msg(ERR_WORK_WITH_TAMPER), rc) == TIMEOUT_OPTION)
			return TIMEOUT_OPTION;
		return rc;
	}

	// The memory of the Tamper device was read successfully,
	// So, it must be checked to verify that there was no
	// tamper event. Generally if PrivateServer case was opened
	// Master Keys buffer contains 0xFF in each byte.
	if(!memcmp(SVMK_FROM_TAMPER,TAMPER_EVENT, SVMK_LENGTH))
	{
		// If we are here it means that the PrivateServer Box
		// was opened.Values are not the same, display a nice message
		// to the console, and ask the user for the next steps.
        csvh_err        (ERR_FLG_LOG,      MSG_TAMPERING_DETECTED4);
		send_snmp_trap(PSV_SNMP_TAMPER_EVENT_OCCURED);
		if ( _csvh_err       ("Tamper Event",  csvh_msg(MSG_TAMPERING_DETECTED1)) == TIMEOUT_OPTION)
			rc = TIMEOUT_OPTION;
		else
			rc = -1;
	}

	// Just to prevent from SVMK part remain in the memory.
	memset(SVMK_FROM_TAMPER,0,sizeof(SVMK_FROM_TAMPER));
	return rc;

#endif

	return rc;
}

/*****************************************************
*	This function turns on the semaphore so that the *
*	starter service will show its menu.				 *
******************************************************/
int  raise_sem()
{
	int rc = 0;
	struct Global_data* Pglobal_data = GPglobal_data();

	// raise the shutdown flag
	Pglobal_data->Shut_down_msg=1;


	// create the event semaphore
	rc = DosCreateEventSem( "Global\\PSV4_ARCS_EVENT", &ARCS_Sem, FALSE, FALSE);
	if (rc)
	{
	    csvh_err (ERR_FLG_LOG, ERR_SCR_NOT_INITIATED);
		return rc;
	}

	rc = DosPostEventSem(ARCS_Sem);
	if (rc) return rc;

	return rc;
}

#define TITLE_FUNC "csv_title_func"

/************************************************************************
*	This function checks if a extfunc_dll_name already loaded. If not	*
*	it loads it and set is_extfunc_dll_loaded to be True.				*
*************************************************************************/
int is_extfunc_dll_exist(char *extfunc_dll_name, int *is_extfunc_dll_loaded,HANDLE	*phMod,
							char   *Title)
{
	int				 rc=CSV_OK;
	CSV_TITLEFUNC    title_func=NULL;

	if (*is_extfunc_dll_loaded==FALSE)
	{
		rc = DosLoadModule(extfunc_dll_name, phMod);
		if (rc==CSV_OK)
		{
			rc = get_function_add((void **)&title_func, phMod, TITLE_FUNC);
			if (rc)
			{
				// If we fail, we write an error to the console and to the log
				_csvh_err(NULL, csvh_msg(MSG_EXTFUNC_UNAVAILABLE));
				*is_extfunc_dll_loaded=FALSE;
			}
			else
			{
				title_func(Title);
				*is_extfunc_dll_loaded=TRUE;
			}
		}
		else
		{
			*is_extfunc_dll_loaded=FALSE;
		}
	}

	return *is_extfunc_dll_loaded;

}

int get_function_add(void **p_func, HANDLE	*phMod, char *FuncName)
{
	if ( ((*p_func) = PSV_LoadFunction(*phMod,FuncName)) == NULL )
		return -1;

	return CSV_OK;
}

