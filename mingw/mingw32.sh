
# Author: David Guillen Fandos <david@davidgf.net>
#
# Downloads and builds mingw-w64 (run in an empty folder)
# Contains a patch which reduces the size of the executables
# (both DLL and EXE) by removing the error messages.
# Those messages rely on a fprintf function which is statically
# linked (not the msvcrt.dll one) and thus add some overhead
# to the executable

VERSION="2.0.7"
wget "http://switch.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v$VERSION.tar.gz"
tar xf mingw-w64-v$VERSION.tar.gz
cd mingw-w64-v$VERSION

patch mingw-w64-crt/crt/pseudo-reloc.c << EOF
--- pseudo-reloc.c	2011-12-20 22:44:38.000000000 +0100
+++ pseudo-reloc.c_	2012-07-23 19:41:54.000000000 +0200
@@ -78,82 +78,8 @@
   DWORD version;
 } runtime_pseudo_reloc_v2;
 
-static void ATTRIBUTE_NORETURN
-__report_error (const char *msg, ...)
-{
-#ifdef __CYGWIN__
-  /* This function is used to print short error messages
-   * to stderr, which may occur during DLL initialization
-   * while fixing up 'pseudo' relocations. This early, we
-   * may not be able to use cygwin stdio functions, so we
-   * use the win32 WriteFile api. This should work with both
-   * normal win32 console IO handles, redirected ones, and
-   * cygwin ptys.
-   */
-  char buf[SHORT_MSG_BUF_SZ];
-  wchar_t module[MAX_PATH];
-  char * posix_module = NULL;
-  static const char   UNKNOWN_MODULE[] = "<unknown module>: ";
-  static const size_t UNKNOWN_MODULE_LEN = sizeof (UNKNOWN_MODULE) - 1;
-  static const char   CYGWIN_FAILURE_MSG[] = "Cygwin runtime failure: ";
-  static const size_t CYGWIN_FAILURE_MSG_LEN = sizeof (CYGWIN_FAILURE_MSG) - 1;
-  DWORD len;
-  DWORD done;
-  va_list args;
-  HANDLE errh = GetStdHandle (STD_ERROR_HANDLE);
-  ssize_t modulelen = GetModuleFileNameW (NULL, module, sizeof (module));
+#define __report_error(...) abort();
 
-  if (errh == INVALID_HANDLE_VALUE)
-    cygwin_internal (CW_EXIT_PROCESS,
-                     STATUS_ILLEGAL_DLL_PSEUDO_RELOCATION,
-                     1);
-
-  if (modulelen > 0)
-    posix_module = cygwin_create_path (CCP_WIN_W_TO_POSIX, module);
-
-  va_start (args, msg);
-  len = (DWORD) vsnprintf (buf, SHORT_MSG_BUF_SZ, msg, args);
-  va_end (args);
-  buf[SHORT_MSG_BUF_SZ-1] = '\0'; /* paranoia */
-
-  if (posix_module)
-    {
-      WriteFile (errh, (PCVOID)CYGWIN_FAILURE_MSG,
-                 CYGWIN_FAILURE_MSG_LEN, &done, NULL);
-      WriteFile (errh, (PCVOID)posix_module,
-                 strlen(posix_module), &done, NULL);
-      WriteFile (errh, (PCVOID)": ", 2, &done, NULL);
-      WriteFile (errh, (PCVOID)buf, len, &done, NULL);
-      free (posix_module);
-    }
-  else
-    {
-      WriteFile (errh, (PCVOID)CYGWIN_FAILURE_MSG,
-                 CYGWIN_FAILURE_MSG_LEN, &done, NULL);
-      WriteFile (errh, (PCVOID)UNKNOWN_MODULE,
-                 UNKNOWN_MODULE_LEN, &done, NULL);
-      WriteFile (errh, (PCVOID)buf, len, &done, NULL);
-    }
-  WriteFile (errh, (PCVOID)"\n", 1, &done, NULL);
-
-  cygwin_internal (CW_EXIT_PROCESS,
-                   STATUS_ILLEGAL_DLL_PSEUDO_RELOCATION,
-                   1);
-  /* not reached, but silences noreturn warning */
-  abort ();
-#else
-  va_list argp;
-  va_start (argp, msg);
-# ifdef __MINGW64_VERSION_MAJOR
-  fprintf (stderr, "Mingw-w64 runtime failure:\n");
-# else
-  fprintf (stderr, "Mingw runtime failure:\n");
-# endif
-  vfprintf (stderr, msg, argp);
-  va_end (argp);
-  abort ();
-#endif
-}
EOF

./configure --host=i686-w64-mingw32 | tee ../log.txt

make -j3 -C mingw-w64-crt  lib32/libmingw32.a | tee -a ../log.txt

mv mingw-w64-crt/lib32/libmingw32.a ../


