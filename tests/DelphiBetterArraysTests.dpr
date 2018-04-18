program DelphiBetterArraysTests;

{$IFDEF CONSOLE_TESTRUNNER}
//{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  BetterArrayTests in 'BetterArrayTests.pas';

{$R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;
  DUnitTestRunner.RunRegisteredTests;
end.

