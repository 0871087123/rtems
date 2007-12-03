/*
 *
 *  Instantatiate a new terminal shell.
 *
 *  Author:
 *
 *   WORK: fernando.ruiz@ctv.es
 *   HOME: correo@fernando-ruiz.com
 *
 *   Thanks at:
 *    Chris John
 *
 *  $Id$
 */
#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <stdio.h>
#include <time.h>

#include <rtems.h>
#include <rtems/error.h>
#include <rtems/libio.h>
#include <rtems/libio_.h>
#include <rtems/system.h>
#include <rtems/shell.h>

#include <termios.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <pwd.h>

/* ----------------------------------------------- *
 * This is a stupidity but is cute.
 * ----------------------------------------------- */
uint32_t   new_rtems_name(char * rtems_name) {
  static char b[5];
  sprintf(b,"%-4.4s",rtems_name);
  return rtems_build_name(b[0],b[1],b[2],b[3]);
}
/* **************************************************************
 * common linked list of shell commands.
 * Because the help report is very long
 * I have a topic for each command.
 * Help list the topics
 * help [topic] list the commands for the topic
 * help [command] help for the command
 * Can you see help rtems monitor report?
 * ************************************************************** */

struct shell_topic_tt;
typedef struct shell_topic_tt shell_topic_t;

struct shell_topic_tt {
  char * topic;
  shell_topic_t * next;
};


static shell_cmd_t   * shell_first_cmd;
static shell_topic_t * shell_first_topic;

shell_env_t *shell_init_env(shell_env_t *);

/* ----------------------------------------------- *
 * Using Chain I can reuse the rtems code.
 * I am more comfortable with this, sorry.
 * ----------------------------------------------- */
shell_topic_t * shell_lookup_topic(char * topic) {
  shell_topic_t * shell_topic;
  shell_topic=shell_first_topic;
  while (shell_topic) {
   if (!strcmp(shell_topic->topic,topic)) return shell_topic;
   shell_topic=shell_topic->next;
  };
  return (shell_topic_t *) NULL;
}
/* ----------------------------------------------- */
shell_topic_t * shell_add_topic(char * topic) {
 shell_topic_t * current,*aux;
 if (!shell_first_topic) {
  aux=malloc(sizeof(shell_topic_t));
  aux->topic=topic;
  aux->next=(shell_topic_t*)NULL;
  return shell_first_topic=aux;
 } else {
  current=shell_first_topic;
  if (!strcmp(topic,current->topic)) return current;
  while (current->next) {
   if (!strcmp(topic,current->next->topic)) return current->next;
   current=current->next;
  };
  aux=malloc(sizeof(shell_topic_t));
  aux->topic=topic;
  aux->next=(shell_topic_t*)NULL;
  current->next=aux;
  return aux;
 };
}
/* ----------------------------------------------- */
shell_cmd_t * shell_lookup_cmd(char * cmd) {
  shell_cmd_t * shell_cmd;
  shell_cmd=shell_first_cmd;
  while (shell_cmd) {
   if (!strcmp(shell_cmd->name,cmd)) return shell_cmd;
   shell_cmd=shell_cmd->next;
  };
  return (shell_cmd_t *) NULL;
}
/* ----------------------------------------------- */
shell_cmd_t * shell_add_cmd(char * cmd,
          char * topic,
          char * usage,
                      shell_command_t command) {
  int shell_help(int argc,char * argv[]);
  shell_cmd_t * shell_cmd,*shell_pvt;
  if (!shell_first_cmd) {
   shell_first_cmd=(shell_cmd_t *) malloc(sizeof(shell_cmd_t));
   shell_first_cmd->name   ="help";
   shell_first_cmd->topic  ="help";
   shell_first_cmd->usage  ="help [topic] # list of usage of commands";
   shell_first_cmd->command=shell_help;
   shell_first_cmd->alias  =(shell_cmd_t *) NULL;
   shell_first_cmd->next   =(shell_cmd_t *) NULL;
   shell_add_topic(shell_first_cmd->topic);
   register_cmds();
  };
  if (!cmd)     return (shell_cmd_t *) NULL;
  if (!command) return (shell_cmd_t *) NULL;
  shell_cmd=(shell_cmd_t *) malloc(sizeof(shell_cmd_t));
  shell_cmd->name   =cmd;
  shell_cmd->topic  =topic;
  shell_cmd->usage  =usage;
  shell_cmd->command=command;
  shell_cmd->alias  =(shell_cmd_t *) NULL;
  shell_cmd->next   =(shell_cmd_t *) NULL;
  shell_add_topic(shell_cmd->topic);
  shell_pvt=shell_first_cmd;
  while (shell_pvt->next) shell_pvt=shell_pvt->next;
  return shell_pvt->next=shell_cmd;
}
/* ----------------------------------------------- *
 * you can make an alias for every command.
 * ----------------------------------------------- */
shell_cmd_t * shell_alias_cmd(char * cmd, char * alias) {
  shell_cmd_t * shell_cmd,* shell_aux;
  shell_aux=(shell_cmd_t *) NULL;
  if (alias) {
   if ((shell_aux=shell_lookup_cmd(alias))!=NULL) {
    return NULL;
   };
   if ((shell_cmd=shell_lookup_cmd(cmd))!=NULL) {
    shell_aux=shell_add_cmd(alias,shell_cmd->topic,
                shell_cmd->usage,shell_cmd->command);
    if (shell_aux) shell_aux->alias=shell_cmd;
   };
  };
  return shell_aux;
}
/* ----------------------------------------------- *
 * Poor but enough..
 * TODO: Redirection capture. "" evaluate, ... C&S welcome.
 * ----------------------------------------------- */
int shell_make_args(char * cmd,
     int  * pargc,
     char * argv[]) {
  int argc=0;
  while ((cmd=strtok(cmd," \t\r\n"))!=NULL) {
    argv[argc++]=cmd;
    cmd=(char*)NULL;
   };
  argv[argc]=(char*)NULL;
  return *pargc=argc;
}
/* ----------------------------------------------- *
 * show the help for one command.
 * ----------------------------------------------- */
int shell_help_cmd(shell_cmd_t * shell_cmd) {
  char * pc;
  int    col,line;
  printf("%-10.10s -",shell_cmd->name);
  col=12;
  line=1;
  if (shell_cmd->alias) {
   printf("is an <alias> for command '%s'",shell_cmd->alias->name);
  } else
  if (shell_cmd->usage) {
   pc=shell_cmd->usage;
   while (*pc) {
    switch(*pc) {
     case '\r':break;
     case '\n':putchar('\n');
               col=0;
               break;
     default  :putchar(*pc);
               col++;
               break;
    };
    pc++;
    if(col>78) { /* What daring... 78?*/
     if (*pc) {
      putchar('\n');
      col=0;
     };
    };
    if (!col && *pc) {
      printf("            ");
      col=12;line++;
    };
   };
  };
  puts("");
  return line;
}
/* ----------------------------------------------- *
 * show the help. The first command implemented.
 * Can you see the header of routine? Known?
 * The same with all the commands....
 * ----------------------------------------------- */
int shell_help(int argc,char * argv[]) {
  int col,line,arg;
  shell_topic_t *topic;
  shell_cmd_t * shell_cmd=shell_first_cmd;
  if (argc<2) {
   printf("help: ('r' repeat last cmd - 'e' edit last cmd)\n"
          "  TOPIC? The topics are\n");
   topic=shell_first_topic;
   col=0;
   while (topic) {
    if (!col){
     col=printf("   %s",topic->topic);
    } else {
     if ((col+strlen(topic->topic)+2)>78){
      printf("\n");
      col=printf("   %s",topic->topic);
     } else {
      col+=printf(", %s",topic->topic);
     };
    };
    topic=topic->next;
   };
   printf("\n");
   return 1;
  };
  line=0;
  for (arg=1;arg<argc;arg++) {
   if (line>16) {
    printf("Press any key to continue...");getchar();
    printf("\n");
    line=0;
   };
   topic=shell_lookup_topic(argv[arg]);
   if (!topic){
    if ((shell_cmd=shell_lookup_cmd(argv[arg]))==NULL) {
     printf("help: topic or cmd '%s' not found. Try <help> alone for a list\n",
            argv[arg]);
     line++;
    } else {
     line+=shell_help_cmd(shell_cmd);
    }
    continue;
   };
   printf("help: list for the topic '%s'\n",argv[arg]);
   line++;
   while (shell_cmd) {
    if (!strcmp(topic->topic,shell_cmd->topic))
     line+=shell_help_cmd(shell_cmd);
    if (line>16) {
     printf("Press any key to continue...");
     getchar();
     printf("\n");
     line=0;
    };
    shell_cmd=shell_cmd->next;
   };
  };
  puts("");
  return 0;
}
/* ----------------------------------------------- *
 * TODO: Add improvements. History, edit vi or emacs, ...
 * ----------------------------------------------- */
int shell_scanline(char * line,int size,FILE * in,FILE * out) {
  int c,col;
  col=0;
  if (*line) {
   col=strlen(line);
   if (out) fprintf(out,"%s",line);
  };
  tcdrain(fileno(in));
  if (out) tcdrain(fileno(out));
  for (;;) {
   line[col]=0;
   c = fgetc(in);
   switch (c) {
    case 0x04:/*Control-d*/
        if (col) break;
    case EOF :return 0;
    case '\n':break;
    case '\f':if (out) fputc('\f',out);
    case 0x03:/*Control-C*/
        line[0]=0;
    case '\r':if (out) fputc('\n',out);
        return 1;
    case  127:
    case '\b':if (col) {
         if (out) {
          fputc('\b',out);
          fputc(' ',out);
          fputc('\b',out);
         };
         col--;
        } else {
         if (out) fputc('\a',out);
        };
        break;
    default  :if (!iscntrl(c)) {
    if (col<size-1) {
     line[col++]=c;
           if (out) fputc(c,out);
    } else {
            if (out) fputc('\a',out);
    };
        } else {
          if (out)
     if (c=='\a') fputc('\a',out);
        };
        break;
   };
  };
}
/* ----------------------------------------------- *
 * - The shell TASK
 * Poor but enough..
 * TODO: Redirection. Tty Signals. ENVVARs. Shell language.
 * ----------------------------------------------- */
shell_env_t  global_shell_env;
shell_env_t *current_shell_env;

extern char **environ;

void cat_file(FILE * out,char * name) {
  FILE * fd;
  int c;
  if (out) {
    fd=fopen(name,"r");
    if (fd) {
       while ((c=fgetc(fd))!=EOF) fputc(c,out);
     fclose(fd);
    };
  };
}

void write_file(char * name,char * content) {
  FILE * fd;
  fd=fopen(name,"w");
  if (fd) {
     fwrite(content,1,strlen(content),fd);
   fclose(fd);
  };
}

void init_issue(void) {
 static char issue_inited=FALSE;
 struct stat buf;
 if (issue_inited) return;
 issue_inited=TRUE;
 getpwnam("root"); /* dummy call to init /etc dir */
 if (stat("/etc/issue",&buf))
  write_file("/etc/issue",
       "Welcome to @V\\n"
       "Login into @S\\n");
 if (stat("/etc/issue.net",&buf))
  write_file("/etc/issue.net",
       "Welcome to %v\n"
       "running on %m\n");
}

int shell_login(FILE * in,FILE * out) {
  FILE          *fd;
  int            c;
  time_t         t;
  int            times;
  char           name[128];
  char           pass[128];
  struct passwd *passwd;

  init_issue();
  setuid(0);
  setgid(0);
  rtems_current_user_env->euid =
  rtems_current_user_env->egid =0;

  if (out) {
    if ((current_shell_env->devname[5]!='p')||
        (current_shell_env->devname[6]!='t')||
        (current_shell_env->devname[7]!='y')) {
      fd = fopen("/etc/issue","r");
      if (fd) {
        while ((c=fgetc(fd))!=EOF) {
          if (c=='@')  {
            switch(c=fgetc(fd)) {
              case 'L':
                fprintf(out,"%s",current_shell_env->devname);
                break;
              case 'B':
                fprintf(out,"0");
                break;
              case 'T':
              case 'D':
                time(&t);
                fprintf(out,"%s",ctime(&t));
                break;
              case 'S':
                fprintf(out,"RTEMS");
                break;
              case 'V':
                fprintf(out,"%s\n%s",_RTEMS_version,_Copyright_Notice);
                break;
              case '@':
                fprintf(out,"@");
                break;
              default :
                fprintf(out,"@%c",c);
                break;
            }
          } else if (c=='\\')  {
            switch(c=fgetc(fd)) {
              case '\\': fprintf(out,"\\"); break;
              case 'b':  fprintf(out,"\b"); break;
              case 'f':  fprintf(out,"\f"); break;
              case 'n':  fprintf(out,"\n"); break;
              case 'r':  fprintf(out,"\r"); break;
              case 's':  fprintf(out," ");  break;
              case 't':  fprintf(out,"\t"); break;
              case '@':  fprintf(out,"@");  break;
            }
          } else {
            fputc(c,out);
          }
        }
        fclose(fd);
      }
    } else {
      fd = fopen("/etc/issue.net","r");
      if (fd) {
        while ((c=fgetc(fd))!=EOF) {
          if (c=='%')  {
            switch(c=fgetc(fd)) {
              case 't':
                fprintf(out,"%s",current_shell_env->devname);
                break;
              case 'h':
                fprintf(out,"0");
                break;
              case 'D':
                fprintf(out," ");
                break;
              case 'd':
                time(&t);
                fprintf(out,"%s",ctime(&t));
                break;
              case 's':
                fprintf(out,"RTEMS");
                break;
              case 'm':
                fprintf(out,"(" CPU_NAME "/" CPU_MODEL_NAME ")");
                break;
              case 'r':
                fprintf(out,_RTEMS_version);
                break;
              case 'v':
                fprintf(out,"%s\n%s",_RTEMS_version,_Copyright_Notice);
	        break;
	      case '%':fprintf(out,"%%");
	        break;
	      default:
                fprintf(out,"%%%c",c);
                break;
            }
          } else {
            fputc(c,out);
          }
        }
        fclose(fd);
      }
    }
  }

  times=0;
  strcpy(name,"");
  strcpy(pass,"");
  for (;;) {
    times++;
    if (times>3) break;
    if (out) fprintf(out,"\nlogin: ");
    if (!shell_scanline(name,sizeof(name),in,out )) break;
    if (out) fprintf(out,"Password: ");
    if (!shell_scanline(pass,sizeof(pass),in,NULL)) break;
    if (out) fprintf(out,"\n");
    if ((passwd=getpwnam(name))) {
      if (strcmp(passwd->pw_passwd,"!")) { /* valid user */
        setuid(passwd->pw_uid);
        setgid(passwd->pw_gid);
        rtems_current_user_env->euid =
        rtems_current_user_env->egid =0;
        chown(current_shell_env->devname,passwd->pw_uid,0);
        rtems_current_user_env->euid = passwd->pw_uid;
        rtems_current_user_env->egid = passwd->pw_gid;
        if (!strcmp(passwd->pw_passwd,"*")) {
         /* /etc/shadow */
         return 0;
        } else {
         /* crypt() */
         return 0;
        }
      }
    }
    if (out)
      fprintf(out,"Login incorrect\n");
    strcpy(name,"");
    strcpy(pass,"");
  }
  return -1;
}

#if 0
void shell_print_env(
  shell_env_t * shell_env
)
{
  if ( !shell_env ) {
    printk( "shell_env is NULL\n" );
    return;
  }
  printk( "shell_env=%p\n"
    "shell_env->magic=0x%08x\t"
    "shell_env->devname=%s\n"
    "shell_env->taskname=%s\t"
    "shell_env->tcflag=%d\n"
    "shell_env->exit_shell=%d\t"
    "shell_env->forever=%d\n",
    shell_env->magic,
    shell_env->devname,
    ((shell_env->taskname) ? shell_env->taskname : "NOT SET"),
    shell_env->tcflag,
    shell_env->exit_shell,
    shell_env->forever
  );
}
#endif

rtems_task shell_shell(rtems_task_argument task_argument)
{
  shell_env_t * shell_env =(shell_env_t*) task_argument;

   shell_shell_loop( shell_env );
   rtems_task_delete( RTEMS_SELF );
}


rtems_boolean shell_shell_loop(
  shell_env_t *shell_env_arg
)
{
  shell_env_t       *shell_env;
  shell_cmd_t       *shell_cmd;
  rtems_status_code  sc;
  struct termios     term;
  char               curdir[256];
  char               cmd[256];
  char               last_cmd[256]; /* to repeat 'r' */
  int                argc;
  char              *argv[128];

  sc = rtems_task_variable_add(RTEMS_SELF,(void*)&current_shell_env,free);
  if (sc != RTEMS_SUCCESSFUL) {
    rtems_error(sc,"rtems_task_variable_add(current_shell_env):");
    return FALSE;
  };

  shell_env         = 
  current_shell_env = shell_init_env( shell_env_arg );
 
  setuid(0);
  setgid(0);
  rtems_current_user_env->euid =
  rtems_current_user_env->egid = 0;

  setvbuf(stdin,NULL,_IONBF,0); /* Not buffered*/
  /* make a raw terminal,Linux Manuals */
  if (tcgetattr (fileno(stdin), &term)>=0) {
   term.c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL|IXON);
   term.c_oflag &= ~OPOST;
   term.c_oflag |= (OPOST|ONLCR); /* But with cr+nl on output */
   term.c_lflag &= ~(ECHO|ECHONL|ICANON|ISIG|IEXTEN);
   if (shell_env->tcflag)
     term.c_cflag = shell_env->tcflag;
   term.c_cflag  |= CLOCAL | CREAD;
   term.c_cc[VMIN]  = 1;
   term.c_cc[VTIME] = 0;
   if (tcsetattr (fileno(stdin), TCSADRAIN, &term) < 0) {
     fprintf(stderr,
       "shell:cannot set terminal attributes(%s)\n",shell_env->devname);
   };
   setvbuf(stdout,NULL,_IONBF,0); /* Not buffered*/
  }

  shell_add_cmd(NULL,NULL,NULL,NULL); /* init the chain list*/
  do {
    /* Set again root user and root filesystem, side effect of set_priv..*/
    sc = rtems_libio_set_private_env();
    if (sc != RTEMS_SUCCESSFUL) {
      rtems_error(sc,"rtems_libio_set_private_env():");
      return FALSE;
    }
    if (!shell_login(stdin,stdout))  {
      cat_file(stdout,"/etc/motd");
      strcpy(last_cmd,"");
      strcpy(cmd,"");
      printf("\n"
        "RTEMS SHELL (Ver.1.0-FRC):%s. "__DATE__". 'help' to list commands.\n",
        shell_env->devname);
      chdir("/"); /* XXX: chdir to getpwent homedir */
      shell_env->exit_shell=FALSE;
      for (;;) {
        /* Prompt section */
        /* XXX: show_prompt user adjustable */
        getcwd(curdir,sizeof(curdir));
        printf( "%s%s[%s] %c ",
          ((shell_env->taskname) ? shell_env->taskname : ""),
          ((shell_env->taskname) ? " " : ""),
          curdir,
          geteuid()?'$':'#'
        );
        /* getcmd section */
        if (!shell_scanline(cmd,sizeof(cmd),stdin,stdout)) {
          break; /*EOF*/
        }

        /* evaluate cmd section */
        if (!strcmp(cmd,"e")) {         /* edit last command */
          strcpy(cmd,last_cmd);
          continue;
        } else if (!strcmp(cmd,"r")) {  /* repeat last command */
          strcpy(cmd,last_cmd);
        } else if (!strcmp(cmd,"bye")) { /* exit to telnetd */
          printf("Shell exiting\n" );
          return TRUE;
        } else if (!strcmp(cmd,"exit")) { /* exit application */
          printf("System shutting down at user request\n" );
          exit(0);
        } else if (!strcmp(cmd,"")) {    /* only for get a new prompt */
          strcpy(last_cmd,cmd);
        }

        /* exec cmd section */
        /* TODO:
         *  To avoid user crash catch the signals.
         *  Open a new stdio files with posibility of redirection *
         *  Run in a new shell task background. (unix &)
         *  Resuming. A little bash.
         */
        if (shell_make_args(cmd,&argc,argv)) {
          if ((shell_cmd=shell_lookup_cmd(argv[0]))!=NULL) {
            shell_env->errorlevel=shell_cmd->command(argc,argv);
          } else {
            printf("shell:%s command not found\n",argv[0]);
            shell_env->errorlevel=-1;
          }
        }
        /* end exec cmd section */

        if (shell_env->exit_shell)
          break;
        strcpy(last_cmd, cmd);
        cmd[0]=0;
      }
      printf("\nGoodbye from RTEMS SHELL :-(\n");
      fflush( stdout );
      fflush( stderr );
    }
  } while (shell_env->forever);
  return TRUE;
}

/* ----------------------------------------------- */
rtems_status_code   shell_init (
  char                *task_name,
  uint32_t             task_stacksize,
  rtems_task_priority  task_priority,
  char                *devname,
  tcflag_t             tcflag,
  int                  forever
)
{
  rtems_id           task_id;
  rtems_status_code  sc;
  shell_env_t       *shell_env;

  sc = rtems_task_create(
    new_rtems_name(task_name),
    task_priority,
    task_stacksize?task_stacksize:RTEMS_MINIMUM_STACK_SIZE,
    RTEMS_DEFAULT_MODES,
    RTEMS_LOCAL | RTEMS_FLOATING_POINT,
    &task_id
  );
  if (sc != RTEMS_SUCCESSFUL) {
    rtems_error(sc,"creating task %s in shell_init()",task_name);
    return sc;
  }

  shell_env = shell_init_env( NULL );
  if ( !shell_env )  {
   rtems_error(sc,"allocating shell_env %s in shell_init()",task_name);
   return RTEMS_NO_MEMORY;
  }
  shell_env->devname    = devname;
  shell_env->taskname   = task_name;
  shell_env->tcflag     = tcflag;
  shell_env->exit_shell = FALSE;
  shell_env->forever    = forever;

  return rtems_task_start(task_id,shell_shell,(rtems_task_argument) shell_env);
}

shell_env_t *shell_init_env(
  shell_env_t *shell_env_arg
)
{
  shell_env_t *shell_env;
  
  shell_env = shell_env_arg;

  if ( !shell_env ) {
    shell_env = malloc(sizeof(shell_env_t));
    if ( !shell_env )
     return NULL;
  }

  if (global_shell_env.magic != new_rtems_name("SENV")) {
    global_shell_env.magic      = new_rtems_name("SENV");
    global_shell_env.devname    = "";
    global_shell_env.taskname   = "GLOBAL";
    global_shell_env.tcflag     = 0;
    global_shell_env.exit_shell = 0;
    global_shell_env.forever    = TRUE;
  }

  *shell_env = global_shell_env;
  shell_env->taskname = NULL;
  shell_env->forever = FALSE;

  return shell_env;
}
