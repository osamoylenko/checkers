unit checkerlogic;

interface
uses Dialogs, SysUtils, log;

type
 p_Tchecker=^Tchecker;
 p_Tcell=^Tcell;
 p_Tboard=^Tboard;

 Tchecker=object  //шашка
  white:boolean;
  queen:boolean;
  cell:p_Tcell;
  constructor init (w:boolean;cell_:p_Tcell);
  function move(r,c:integer):boolean;
  function can_move_to(r,c:integer):boolean;
  function can_eat_to (r,c:integer):p_Tchecker;
  function can_move_any:boolean;
  function can_eat_any:boolean;
 end;

 Tcell=object   //ячейка
  checker:^Tchecker;
  board:^Tboard;
  r,c:integer;//строка и столбец
  constructor init (r_,c_:integer; board_:p_Tboard);
 end;

 Tboard=object  //доска
  cell:array [1..8,1..8] of p_Tcell;
  white_turn:boolean;
  checker_continue_eating : p_Tchecker; // шашка, которая продолжает есть
  procedure Init;
  procedure Start;
  procedure Free;
  function select_cell(r,c:integer):p_Tcell;
  procedure move(r1,c1,r2,c2:integer);
  function eat_exist:boolean;
  function move_exist:boolean;

 end;


implementation

 constructor Tchecker.init (w:boolean;cell_:p_Tcell);
 begin
  white:=w;
  queen:=false;
  cell:=cell_;
 end;

function Tchecker.can_move_to(r,c:integer):boolean;
var i,r_old,c_old,rd,cd:integer;
    board:p_Tboard;
    dest_cell:p_Tcell;
begin
  can_move_to:=false;
  board:=cell^.board;
  r_old:=cell^.r;
  c_old:=cell^.c;
  dest_cell:=board^.select_cell(r,c);
  if (dest_cell <> nil) and not ((r=r_old) and (c=c_old)) and (white=board^.white_turn) then
  begin
   if not queen then
   begin
    if ((white and (r=r_old+1) and ((c=c_old+1) or (c=c_old-1))) or
    ((not white) and (r=r_old-1) and ((c=c_old+1) or (c=c_old-1)))) and (dest_cell^.checker=nil) then can_move_to:=true;
   end
   else
   begin
    if abs (r-r_old)=abs (c-c_old) then
    begin
     rd:=(r-r_old)div abs(r-r_old);          //направление
     cd:=(c-c_old)div abs(c-c_old);
     can_move_to:=true;
     for i:=1 to abs (r-r_old) do
     begin
      dest_cell:=board^.select_cell(r_old+i*rd, c_old+i*cd);
      if (dest_cell=nil) or (dest_cell^.checker<>nil) then can_move_to:=false;
     end;
    end;
   end;
  end;
end;

function Tchecker.can_eat_to (r,c:integer):p_Tchecker;
var i,j,r_old,c_old,rd,cd:integer;
    board:p_Tboard;
    dest_cell:p_Tcell;
    eat_checker:p_Tchecker;
begin
 can_eat_to:=nil;
 board:=cell^.board;
 r_old:=cell^.r;
 c_old:=cell^.c;
 dest_cell:=board^.select_cell(r,c);
 if (dest_cell<>nil) and (abs (r-r_old)=abs (c-c_old)) and not ((r=r_old) and (c=c_old)) and (white=board^.white_turn) then
 begin
  rd:=(r-r_old)div abs(r-r_old);                                        //направление
  cd:=(c-c_old)div abs(c-c_old);
  //ищем съедаемую фигуру
  i:=1;
  eat_checker:=nil;
  while true do
  begin
   dest_cell:=board^.select_cell(r_old+i*rd, c_old+i*cd);
   if dest_cell=nil then break;
   if dest_cell^.checker<>nil then
   begin
    eat_checker:=dest_cell^.checker;
    break;
   end;
   i:=i+1;
   if (i>1) and not queen then break;
  end;
  if (eat_checker<>nil) and (white=not eat_checker^.white) then
  begin
   i:=i+1;
   dest_cell:=board^.select_cell(r_old+i*rd, c_old+i*cd);
   if (dest_cell<>nil) and (dest_cell^.checker=nil) then
   begin
    if not queen then
    begin
     if i=abs (r-r_old) then
      can_eat_to:=eat_checker;
    end
    else
    begin
     can_eat_to:=eat_checker;
     for j:=i to abs (r-r_old) do
     begin
      dest_cell:=board^.select_cell(r_old+j*rd, c_old+j*cd);
      if (dest_cell=nil) or (dest_cell^.checker<>nil) then
      begin
       can_eat_to:=nil;
       break;
      end;
     end;
    end;
   end;
  end;
 end;
end;

function Tchecker.can_eat_any:boolean;
var i,j:integer;
begin
 can_eat_any:=false;
 for i:=1 to 8 do
 begin
  for j:=1 to 8 do
  begin
   if can_eat_to (i,j)<>nil then
   begin
    can_eat_any:=true;
    break;
   end;
  end;
 end;
end;

function Tchecker.can_move_any:boolean;
var i,j:integer;
begin
 can_move_any:=false;
 for i:=1 to 8 do
 begin
  for j:=1 to 8 do
  begin
   if can_move_to (i,j) then
   begin
    can_move_any:=true;
    break;
   end;
  end;
 end;
end;

 function Tchecker.move(r,c:integer):boolean;
 var board:p_Tboard;
     dest_cell:p_Tcell;
     eat_cell:p_Tcell;
     eat_checker:p_Tchecker;
 begin
   move:=false;
   board:=cell^.board;
   dest_cell:=board^.select_cell(r,c);
   if board^.eat_exist then
   begin
    if (board^.checker_continue_eating<>nil) and (board^.checker_continue_eating<>@self) then
    begin
     log_output ('Нужно есть ещё шашкой ' + inttostr(board^.checker_continue_eating^.cell^.r) + ' ' + inttostr(board^.checker_continue_eating^.cell^.c));
     exit;
    end;

    eat_checker:=can_eat_to(r,c);
    if eat_checker<>nil then
    begin
     eat_cell:=eat_checker^.cell;
     cell^.checker:=nil;
     dest_cell^.checker:=@self;
     cell:=dest_cell;
     dispose (eat_cell^.checker);
     eat_cell^.checker:=nil;
     if (white and (r=8)) or (not white and (r=1))then
      queen:=true;
     if can_eat_any then
      board^.checker_continue_eating:=@self     // Можно съесть еще
     else
     begin
      board^.white_turn:=not board^.white_turn;      //  ход окончен
      board^.checker_continue_eating:=nil;
     end;
     move:=true;
    end;
   end
   else
   begin
    if can_move_to (r,c) then
    begin
     cell^.checker:=nil;
     dest_cell^.checker:=@self;
     cell:=dest_cell;
     if (white and (r=8)) or (not white and (r=1))then
      queen:=true;
     board^.white_turn:=not board^.white_turn;
     move:=true;
    end;
   end;
 end;

 constructor Tcell.init (r_,c_:integer; board_:p_Tboard);
 begin
  r:=r_;
  c:=c_;
  board:=board_;
  checker:=nil;
 end;


 procedure Tboard.Init;
 var i,j:integer;
 begin
  white_turn:=true;
  checker_continue_eating := nil;
  for i:=1 to 8 do
   for j:=1 to 8 do
    cell[i,j]:=nil;
 end;

 procedure Tboard.Start;  //доска
 var i,j:integer;
 begin
  Free;
  white_turn:=true;
  checker_continue_eating := nil;
  for i:=1 to 8 do
   for j:=1 to 8 do
   begin
    new(cell[i,j]); //выделили память под ячейку
    cell [i,j]^.init(i,j,@self); //указатель на текущуй объект
    if (i>=1) and (i<=3) and ((i+j) mod 2=0) then
    begin
     new(cell[i,j]^.checker);
     cell[i,j]^.checker^.init(true,cell[i,j]);
    end;
    if (i>=6) and (i<=8) and ((i+j) mod 2=0) then
    begin
     new(cell[i,j]^.checker);
     cell[i,j]^.checker^.init(false,cell[i,j]);
    end;
   end;
end;


 procedure Tboard.Free;
 var i, j:integer;
 begin
  for i:=1 to 8 do
   for j:=1 to 8 do
   begin
    if cell[i,j] <> nil then
    begin
     if cell[i,j]^.checker <> nil then
       dispose(cell[i,j]^.checker);
     dispose(cell[i,j]);
    end;
   end;
 end;

function Tboard.select_cell(r,c:integer):p_Tcell;
Begin
 select_cell:=nil;
 if (r>=1) and (r<=8) and (c>=1) and (c<=8) then
  select_cell:=cell[r,c];
end;

procedure Tboard.move(r1,c1,r2,c2:integer);
var cell1:p_Tcell;
begin
 cell1:=select_cell(r1,c1);
 if cell1=nil then
  log_output ('Неверная исходная ячейка')
 else
 begin
  if cell1^.checker=nil then
   log_output ('Отсутствует фигура для хода')
  else if cell1^.checker^.move(r2,c2) then
   log_output ('Сделали ход: '+inttostr(r1)+' '+inttostr(c1)+' - '+inttostr(r2)+' '+inttostr(c2))
  else
   log_output ('Некорректный ход');
 end;
end;

function Tboard.eat_exist:boolean;
var i,j:integer;
begin
 eat_exist:=false;
 for i:=1 to 8 do
  for j:=1 to 8 do
   if (cell [i,j]^.checker<>nil) and (cell [i,j]^.checker^.white=white_turn) and (cell [i,j]^.checker^.can_eat_any) then
   begin
    eat_exist:=true;
    log_output (inttostr(i)+' '+inttostr(j)+' может есть');
   end;
end;


function Tboard.move_exist:boolean;
var i,j:integer;
begin
 move_exist:=false;
 for i:=1 to 8 do
  for j:=1 to 8 do
   if (cell [i,j]^.checker<>nil) and (cell [i,j]^.checker^.white=white_turn) and (cell [i,j]^.checker^.can_move_any) then
   begin
    move_exist:=true;
   end;
end;


end.




