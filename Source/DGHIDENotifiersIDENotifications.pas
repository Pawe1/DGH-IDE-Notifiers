(**

  This module contains a class which implements the IOTAIDENotifier, IOTAIDENotifier50 and
  IOTAIDENotifier80 interfaces to capture file notifiction and compiler notifications in the
  RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    01 Oct 2017

**)
Unit DGHIDENotifiersIDENotifications;

Interface

Uses
  ToolsAPI,
  DGHIDENotificationTypes,
  Classes,
  DGHIDENotifiersModuleNotiferCollection;

{$INCLUDE 'CompilerDefinitions.inc'}

Type
  (** This class implements the IDENotifier interfaces. **)
  TDGHNotificationsIDENotifier = Class(TDGHNotifierObject, IOTAIDENotifier,
    IOTAIDENotifier50, IOTAIDENotifier80)
  Strict Private
    FModuleNotifiers  : IDINModuleNotifierList;
    FProjectNotifiers : IDINModuleNotifierList;
  {$IFDEF D2010} Strict {$ENDIF} Protected
    // IOTAIDENotifier
    Procedure FileNotification(NotifyCode: TOTAFileNotification;
      Const FileName: String; Var Cancel: Boolean);
    // IOTAIDENotifier
    Procedure BeforeCompile(Const Project: IOTAProject; Var Cancel: Boolean); Overload;
    Procedure AfterCompile(Succeeded: Boolean); Overload;
    // IOTAIDENotifier50
    Procedure BeforeCompile(Const Project: IOTAProject; IsCodeInsight: Boolean;
      Var Cancel: Boolean); Overload;
    Procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean); Overload;
    // IOTAIDENotifier80
    Procedure AfterCompile(Const Project: IOTAProject; Succeeded:
      Boolean; IsCodeInsight: Boolean); Overload;
  Public
    Constructor Create(Const strNotifier, strFileName : String;
      Const iNotification : TDGHIDENotification); Override;
    Destructor Destroy; Override;
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  DGHIDENotificationsCommon,
  DGHIDENotifiersModuleNotifications,
  DGHIDENotifiersProjectNotifications,
  DGHIDENotifiersFormNotifications;

{ TDGHNotifiersIDENotifications }

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access to the Project, whether the compilation was successful and whether it was
           invoked by CodeInsight.

  @param   Project       as an IOTAProject as a constant
  @param   Succeeded     as a Boolean
  @param   IsCodeInsight as a Boolean

**)
Procedure TDGHNotificationsIDENotifier.AfterCompile(Const Project: IOTAProject;
  Succeeded, IsCodeInsight: Boolean);

Begin
  DoNotification(
    Format(
    '80.AfterCompile = Project: %s, Succeeded: %s, IsCodeInsight: %s',
      [
        GetProjectFileName(Project),
        strBoolean[Succeeded],
        strBoolean[IsCodeInsight]
      ])
  );
End;

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access whether the compilation was successful and whether it was invoked by
           CodeInsight.

  @param   Succeeded     as a Boolean
  @param   IsCodeInsight as a Boolean

**)
Procedure TDGHNotificationsIDENotifier.AfterCompile(Succeeded, IsCodeInsight: Boolean);

Begin
  DoNotification(
    Format(
    '50.AfterCompile = Succeeded: %s, IsCodeInsight: %s',
      [
        strBoolean[Succeeded],
        strBoolean[IsCodeInsight]
      ])
  );
End;

(**

  This method is called after a project is compiled.

  @precon  None.
  @postcon Provides access whether the compilation was successful.

  @param   Succeeded     as a Boolean

**)
Procedure TDGHNotificationsIDENotifier.AfterCompile(Succeeded: Boolean);

Begin
  DoNotification(
    Format(
    '.AfterCompile = Succeeded: %s',
      [
        strBoolean[Succeeded]
      ])
  );
End;

(**

  This method is called before a project is compiled.

  @precon  None.
  @postcon Provides access to the Project being compiled and whether the compile was invoked by
           CodeInsight.

  @param   Project       as an IOTAProject as a constant
  @param   IsCodeInsight as a Boolean
  @param   Cancel        as a Boolean as a reference

**)
Procedure TDGHNotificationsIDENotifier.BeforeCompile(Const Project: IOTAProject;
  IsCodeInsight: Boolean; Var Cancel: Boolean);

Begin
  DoNotification(
    Format(
    '50.BeforeCompile = Project: %s, IsCodeInsight: %s, Cancel: %s',
      [
        GetProjectFileName(Project),
        strBoolean[IsCodeInsight],
        strBoolean[Cancel]
      ])
  );
End;

(**

  This is a constructor for the TDGHNotificationsIDENotifier class.

  @precon  None.
  @postcon Initialises a string list to store the filenames and their module notifier indexes.

  @param   strNotifier   as a String as a constant
  @param   strFileName   as a String as a constant
  @param   iNotification as a TDGHIDENotification as a constant

**)
Constructor TDGHNotificationsIDENotifier.Create(Const strNotifier, strFileName : String;
  Const iNotification : TDGHIDENotification);

Begin
  {$IFDEF DEBUG}CodeSite.TraceMethod('TDGHNotificationsIDENotifier.Create', tmoTiming);{$ENDIF}
  Inherited Create(strNotifier, strFileName, iNotification);
  FModuleNotifiers := TDINModuleNotifierList.Create;
  FProjectNotifiers := TDINModuleNotifierList.Create;
End;

(**

  This is a destructor for the TDGHNotificationsIDENotifier class.

  @precon  None.
  @postcon Closes any remaining module notifiers and frees the memory.

**)
Destructor TDGHNotificationsIDENotifier.Destroy;

Begin
  {$IFDEF DEBUG}CodeSite.TraceMethod('TDGHNotificationsIDENotifier.Destroy', tmoTiming);{$ENDIF}
  Inherited Destroy;
End;

(**

  This method is called before a project is compiled.

  @precon  None.
  @postcon Provides access to the Project being compiled.

  @param   Project       as an IOTAProject as a constant
  @param   Cancel        as a Boolean as a reference

**)
Procedure TDGHNotificationsIDENotifier.BeforeCompile(Const Project: IOTAProject;
  Var Cancel: Boolean);

Begin
  DoNotification(
    Format(
    '.BeforeCompile = Project: %s, Cancel: %s',
      [
        GetProjectFileName(Project),
        strBoolean[Cancel]
      ])
  );
End;

(**

  This method iscalled when ever a file or package is loaded or unloaded from the IDE.

  @precon  None.
  @postcon Provides access to the Filename and the operation that occurred.

  @param   NotifyCode as a TOTAFileNotification
  @param   FileName   as a String as a constant
  @param   Cancel     as a Boolean as a reference

**)
Procedure TDGHNotificationsIDENotifier.FileNotification(NotifyCode: TOTAFileNotification;
  Const FileName: String; Var Cancel: Boolean);

Const
  strNotifyCode : Array[Low(TOTAFileNotification)..High(TOTAFileNotification)] Of String = (
    'ofnFileOpening',
    'ofnFileOpened',
    'ofnFileClosing',
    'ofnDefaultDesktopLoad',
    'ofnDefaultDesktopSave',
    'ofnProjectDesktopLoad',
    'ofnProjectDesktopSave',
    'ofnPackageInstalled',
    'ofnPackageUninstalled',
    'ofnActiveProjectChanged' {$IFDEF DXE80},
    'ofnProjectOpenedFromTemplate' {$ENDIF}
  );

Var
  MS : IOTAModuleServices;
  M : IOTAModule;
  P : IOTAProject;
  MN : TDNModuleNotifier;
  C : IDINModuleNotifierList;
  iIndex : Integer;

Begin
  DoNotification(
    Format(
    '.FileNotification = NotifyCode: %s, FileName: %s, Cancel: %s',
      [
        strNotifyCode[NotifyCode],
        ExtractFileName(FileName),
        strBoolean[Cancel]
      ])
  );
  If Not Cancel And Supports(BorlandIDEServices, IOTAModuleServices, MS) Then
    Case NotifyCode Of
      ofnFileOpened:
        Begin
          M := MS.OpenModule(FileName);
          If Supports(M, IOTAProject, P) Then
            Begin
              MN := TDNProjectNotifier.Create('IOTAProjectNotifier', FileName, dinProjectNotifier,
                FProjectNotifiers);
              FProjectNotifiers.Add(FileName, M.AddNotifier(MN));
            End Else
            Begin
              MN := TDNModuleNotifier.Create('IOTAModuleNotifier', FileName, dinModuleNotifier,
                FModuleNotifiers);
              FModuleNotifiers.Add(FileName, M.AddNotifier(MN));
            End;
        End;
      ofnFileClosing:
        Begin
          M := MS.OpenModule(FileName);
          If Supports(M, IOTAProject, P) Then
            C := FProjectNotifiers
          Else
            C := FModuleNotifiers;
          iIndex := C.Remove(FileName);
          If iIndex > -1 Then
            M.RemoveNotifier(iIndex);
        End;
    End;
End;

End.


