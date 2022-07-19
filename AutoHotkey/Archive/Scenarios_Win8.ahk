;
; Template.ahk
;
; Sets the general formatting for an AutoHotKey (AHK) script file.
;
; Notes:
; --------------------------------------------------------------------------------------------
;
; 12/27/09:
; - Changed the path for debug.ahk to point to the include directory.
; - Added default logging.
;
; 10/24/09:
; - Added comment space to the header
; - Moved the Startup call above the includes
; 
;
; 04/21/09:
; - Created the template file and formatted various sections
;

;
; #########################
;   Global Initialization
; #########################

;
; Set the title matching to match if the string is found
; anywhere in the title.
;
SetTitleMatchMode, 2

Template_Startup()

#NoEnv
#include %A_ScriptDir%\Include\tools.ahk
#include %A_ScriptDir%\Include\debug.ahk




;
; ###############
;   Scope tools
; ###############
;
; The hotkeys listed below are only active if the active window contains the text "Microsoft" in the title.
; For example, these keys are not active in Notepad, but are active in Microsoft Word.
;
; The keyword can be an exact match, or a partial match of the window title, based on the SetTitleMatchMode setting
; specified at the top of the script.
;
;********************************************************************
#ifwinactive Windows Product Studio
;********************************************************************

!^e::
   Send {Appskey}i
   Sleep 500
   Send ^c
   Send {Escape}
   Send {Appskey}C
   sleep 500 
   Send %clipboard%
   Send {Tab}
   Send Store
   Send {tab 2}
   Send Exp{Tab 2}
   Send {Left 3}
   Send 07/05/10{Tab}
   Send M2
   Send {Tab 4}
   Send Enhanced with Services{Tab}
   Send CynthiaT{Tab}
   Send SeanO{Tab}
   Send davsmith;malamus;bilbakir{Tab 3}

return

;
; Send keboard strokes for the word "Maple" if
; the text underscore ABC is typed while in a window
; with Microsoft in the title.
;
::_ACE::
   LogFunctionStart(A_ThisHotKey)
   Send Maple
   LogFunctionEnd()
return



;
; ################
;   Global tools
; ################
;
; The hotkeys listed below are always active
;
;********************************************************************
#ifwinactive 
;********************************************************************




; ###################
;   Utility Hotkeys
; ###################


; #############
;   Functions
; #############
Template_Startup()
{
   LogFunctionStart(A_ThisFunc)


   strFunc := "TestFunc"
   Loop,3
   {
      Log("Calling " . strFunc)
      %strFunc%("Hello")
   }
   

TEMPLATE_STARTUP_EXIT:
   LogFunctionEnd()
   return
}


^!P::
   Send {Appskey}i
   Sleep 500
   Send ^c
   Send {Escape}
   Send {Appskey}C
   sleep 500 
   strTitle := clipboard
   strKeywords = Store
   strNextValidation = 07/25/2010
   strMilestone = M2
   strPillar = Enhanced with Services
   strPMLeader = CynthiaT
   strTestLeader = SeanO
   strValidators = malamus;davsmith;bilbakir
   strOSFeaturePath = \WSC-Web Services and Content\APPS-App Store and Metadata Services
   strOSFeatureOwner = malamus
;   strDetailLink := "c:\temp\blah.doc"
;   strUXDetailLink := "d:\manny\test.doc"
;   strDesc := "This is some text describing the scenario"
;   strNotes := "These are the notes for the experience"
;   strSteps := "1.Test`rNext test{Tab}"

   Populate_Experience()
return

Populate_Experience()
{
   LogFunctionStart(A_ThisFunc)
   global strTitle
   global strKeywords
   global strNextValidation
   global strMilestone
   global strPillar
   global strPMLeader
   global strTestLeader
   global strValidators
   global strUXDesigner
   global strUXResearcher
   global strOSFeaturePath
   global strOSFeatureOwner
   global strDetailLink
   global strUXDetailLink
   global strDesc
   global strNotes
   global strSteps

   ControlFocus PSBFCustomForm2, Product Studio
   Send %strTitle%
   Send {Tab}
   Send %strKeywords%
   Send {tab 2}
   Send ExperienceItemDetail{Tab 2}
   Send {Left 3}
   Send %strNextValidation%{Tab}
   Send %strMilestone%
   Send {Tab 4}
   Send %stPillar%{Tab}
   Send %strPMLeader%{Tab}
   Send %strTestLeader%{Tab}
   Send %strValidators%{Tab}
   Send %strUXDesigner%{Tab}
   Send %strUXResearcher%{Tab}
   Send %strOSFeaturePath%{Tab}
   Send %strOSFeatureOwner%{Tab}
   Send {Tab}
   Send %strDetailLink%{Tab}
   Send %strUXDetailLink%{Tab}
   Send %strDesc%{Tab}
   Send !S+{Tab}
   Send %strNotes%{Tab}
   Send !S
   Send %strSteps%


goto POPULATE_EXPERIENCE_EXIT

POPULATE_EXPERIENCE_EXIT:
   LogFunctionEnd()
}




