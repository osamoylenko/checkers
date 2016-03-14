unit checkergui;

{$mode objfpc}{$H+}


interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, checkerlogic, log;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Memo1: TMemo;
    Label1 : TLabel;

    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ImageDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ImageDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }

    board:Tboard;
    r_old,c_old:integer;

    checker_image:array [1..24] of TImage;
    image_num:integer;
    procedure DrawBoard;

  public
    { public declarations }

  end;

var
  Form1: TForm1;



implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.DrawBoard;
var i,j:integer;
begin
 for i:=1 to image_num do
  checker_image[i].visible:=false;
 image_num:=0;
 for i:=1 to 8 do
  for j:=1 to 8 do
   begin
    if board.cell[i,j]^.checker <> nil then
    begin
     image_num:=image_num+1;
     checker_image[image_num]:=Timage.create(form1);
     checker_image[image_num].parent:=form1;
     checker_image[image_num].Top:=25+(9-i-1)*54;
     checker_image[image_num].Left:=28+(j-1)*54;
     checker_image[image_num].AutoSize:=true;   //  ВОТ СУКА САМАЯ ГЛАВНАЯ КОМАНДА, КОТОРАЯ ДЕЛАЕТ НОРМ
     if board.cell[i,j]^.checker^.white then
      if board.cell[i,j]^.checker^.queen then
       checker_image[image_num].Picture.LoadFromFile('wssk.png')
      else
       checker_image[image_num].Picture.LoadFromFile('wss.png')
     else
      if board.cell[i,j]^.checker^.queen then
       checker_image[image_num].Picture.LoadFromFile('bssk.png')
      else
       checker_image[image_num].Picture.LoadFromFile('bss.png');
     checker_image[image_num].OnMouseDown:=@ImageMouseDown;
     checker_image[image_num].DragCursor:=crCross;
     checker_image[image_num].Cursor:=crHandPoint
    end;
   end;


 // определяем победу: если нет хода то другие победили!
 if not board.move_exist and not board.eat_exist then
  if board.white_turn then
   Label1.caption := 'Черные победили!!!'
  else
   Label1.caption := 'Белые победили!!!'
 else
  if board.white_turn then
   Label1.caption := 'Белые ходят'
  else
   Label1.caption := 'Чёрные ходят';
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 board.start;
 drawboard;
 memo1.Clear;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  board.free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  image_num:=0;
  set_memo(@memo1);
  board.init;
end;


procedure TForm1.ImageDragDrop(Sender, Source: TObject; X, Y: Integer);
var i,j:integer;
begin
 if Source is TImage then // Если перетаскиваем компонент Image то
begin
 i:=9 - ((y-25) div 54+1);
 j:=(x-28) div 54+1;
 board.move(r_old,c_old,i,j);
 drawboard;
end;
end;

procedure TForm1.ImageDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
 Accept:= (Source is TImage) ;
end;


procedure TForm1.ImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if sender is TImage then
  begin
   x:=TImage(Sender).Left;
   y:=TImage(Sender).Top;
   r_old:=9 - ((y-25) div 54+1);
   c_old:=(x-28) div 54+1;
   TImage(sender).BeginDrag(True);
  end;
end;

end.

