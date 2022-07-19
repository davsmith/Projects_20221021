// SubStr2.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "string.h"


char *SubStr(char *strString, char *strSub);

int _tmain(int argc, _TCHAR* argv[])
{
	char *strSub = NULL;

	strSub = SubStr("abcdefg", "abc");
	strSub = SubStr("abcdefg", "cde");
	strSub = SubStr("abcdefgh", "fgh");
	strSub = SubStr("bcdefgh", "abc");
	strSub = SubStr("bcdefgh", "ghi");
	strSub = SubStr("abcabdef", "abd"); 
	strSub = SubStr("bbbbdc", "bbd"); 
	strSub = SubStr(NULL, "bbd"); 
	strSub = SubStr("abc", NULL); 
	strSub = SubStr("abc", "abcd"); 
	strSub = SubStr("abcabc", "abc"); 

	return 0;
}


char *SubStr(char *strString, char *strSub)
{
	char *ptmpStr=strString;
	char *ptmpSub=strSub;
	char *pRetVal=NULL;

	if ((strString == NULL) || (strSub == NULL))
	{
		return NULL;
	}

	if (strlen(strSub) > strlen(strString))
	{
		return NULL;
	}

	while (*ptmpStr != '\0')
	{
		while ((*ptmpStr != *ptmpSub) && (*ptmpStr != '\0'))
		{
			ptmpStr++;
		}

		pRetVal = ptmpStr;

		while ((*ptmpStr == *ptmpSub) && (*ptmpSub != '\0'))
		{
			ptmpStr++;
			ptmpSub++;
		}

		if (*ptmpSub == '\0')
		{
			return pRetVal;
		}

		ptmpSub = strSub;
	}

	return NULL;
}