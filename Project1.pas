uses
  crt;

type
  
  t_kill_ship = record
    one: 0..4;
    two: 0..4;
    three: 0..4;
    four: 0..4;
  end;
  
  //t_x_y = -1..10;
  t_point = record
    x: shortint;
    y: shortint;
  end;
  t_line_coord = 0..99;
  t_set_line_coord = set of t_line_coord;
  Tdir = (x_up, x_down, y_up, y_down, dir_note);
  t_ship = record 
    coord: t_point;//корордината
    Length: 1..4;//длина
    dir: Tdir;//направление
    beaten: 0..4;//подбитые
  end;
  t_beaten_coord = record
    kill: t_set_line_coord;
    missed: t_set_line_coord;
  end;
  t_ships = record 
    ships: array [1..10] of t_ship;
    beaten_coord: t_beaten_coord;
    area_coord: t_set_line_coord;
    pitch: array [0..9, 0..9] of byte;
    kill_ships: t_kill_ship;
  end;
  
  Trecords = record
    name: string[20];
    score: word;
  end;
  TMenu = record
    items: array[0..6, 0..2] of string;
    activeitem: byte;
  end;
  
  TKey = (kNote, kEnter, kEsc, kUp, kDoun, kRight, kLeft);
  
  
  t_set_pc_dir = set of Tdir;
  
  t_pc_coords = record
    set_pc_dir: t_set_pc_dir;
    dir: Tdir;
    point: t_point;
    buf_point: t_point;
    special_situation: boolean;
    next: boolean;
  end;
  
  t_cursor = record
    delate: boolean;
    draw_ship: boolean;
    change_dir: boolean;
  end;
  
  t_player_coords = record
    Length: byte;
    dir: Tdir;
    point: t_point;
    set_numder_of_ship: set of byte;
    number: byte;
    count: byte;
    cursor: t_cursor;
    show_ship: boolean;
  end;
  
  t_infor_of_coords = record
    pc: t_pc_coords;
    player: t_player_coords;
  end;
  t_ship_kill = record
    pc: boolean;
    player: boolean;
  end;

const
  ramka_up = '╔══════════════════════════╗';
  ramka_down = '╚══════════════════════════╝';
  ramka_up_option = '╔══════════════════╗';
  ramka_down_option = '╚══════════════════╝';
  ramka_up_question = '╔═════╗';
  ramka_down_question = '╚═════╝';

var
  stop_game: boolean;
  isExit_option: boolean;
  restart_game: boolean;
  isExit: boolean;
  mainMenu_change_dir: TMenu;
  mainMenu_variant_of_dir: TMenu;
  mainMenu: Tmenu;
  mainMenu_allocation: Tmenu;
  my_ships: t_ships;
  pc_ships: t_ships;
  mainMenu_variant_of_ships: TMenu;
  mainMenu_option: Tmenu;
  mainMenu_question: Tmenu;
  mainMenu_question2: Tmenu;
  kill_ship: t_ship_kill;
  kill_part_ship: t_ship_kill;
  new_record: Trecords;
  i_symbol: byte;
  infor_of_point: t_infor_of_coords;
  t: file of Trecords;
  t1: Text;

procedure write_count_ships; forward;

procedure clear_area(x1, y1, x2, y2: byte); forward;

procedure about_it; forward;

procedure show_records; forward;

procedure Exit_; forward;

procedure show_game_pitch_1; forward;

procedure show_game_pitch_2; forward;

function translate_coords(point: t_point): t_line_coord; forward;

procedure init_ships_base(var ships_: t_ships); forward;

procedure init_ships_coords(var ships: t_ships); forward;

procedure show_ships(color: byte); forward;

procedure Background; forward;

function getkey(kSymbol: boolean): TKey; forward;

procedure initMenu_option; forward;

procedure nextItem_option; forward;

procedure prevItem_option; forward;

procedure showMenu_option; forward;

procedure runMenu_option; forward;

procedure clear_cache(var ships: t_ships); forward;

function random_point: t_point; forward;

procedure end_game; forward;

procedure regiter_ship(i: byte; var ships: t_ships; var set_: t_set_line_coord; allocation: boolean); forward;

function point_in_pitch(point: t_point): boolean; forward;

procedure draw_display_information; forward;

function is_right_coords(ships: t_ships; i: byte): boolean; forward;

procedure draw_display; forward;

procedure initMenu_question2;
var
  i: byte;
begin
  textcolor(Black);
  for i := 0 to 1 do
    mainMenu_question2.Items[i, 0] := ramka_up_question;
  for i := 0 to 1 do
    mainMenu_question2.Items[i, 2] := ramka_down_question;
  mainMenu_question2.Items[0, 1] := '║ да  ║';
  mainMenu_question2.Items[1, 1] := '║ нет ║';  
  mainMenu_question2.activeItem := 0;
end;

procedure nextItem_question2;
begin
  if   mainMenu_question2.activeItem = 1 then
    mainMenu_question2.activeItem := 0
  else inc(  mainMenu_question2.activeItem);
end;

procedure prevItem_question2;
begin
  if   mainMenu_question2.activeItem = 0 then
    mainMenu_question2.activeItem := 1
  else dec(  mainMenu_question2.activeItem);
end;

procedure show_question_menu2;
var
  posMenu: t_point;
  i, j: byte;
begin
  posMenu.y := 20;
  posMenu.x := 32;
  for i := 0 to 1 do
  begin
    if i = mainMenu_question2.activeitem then
      textBackground(13)
    else  textBackground(Yellow);
    for j := 0 to 2 do
    begin
      gotoXY(posMenu.x, posMenu.y);
      Write(mainMenu_question2.items[i, j]);
      Inc(PosMenu.y); 
    end;
    PosMenu.y := PosMenu.y - 3;
    posMenu.x := posMenu.x + 12;
  end;
  textBackground(2);
end;

procedure runMenu_question2;
var
  b: boolean;
  key: TKey;
  isExit_question2: boolean;
begin
  b := true;
  GotoXY(25, 15);
  Write('Вы действительно хотите выйти ?');
  isExit_question2 := false;
  repeat
    key := getkey(false);
    if key in [kRight, kLeft, kEnter] then
    begin
      case key of
        kLeft: prevItem_question2;
        kRight: nextItem_question2;
        kEnter:
          begin
            case mainMenu_question2.activeItem of
              0: 
                begin
                  isExit_question2 := true;
                  stop_game := true;
                  b := false;
                end;
              1: 
                begin
                  isExit_question2 := true;
                  clear_area(25, 11, 55, 23);
                  draw_display;
                  draw_display_information;
                  b := false;
                end;
            end; 
          end;
      end;
      if b then show_question_menu2;
    end;
  until isExit_question2;
end;



function translate_coords_on_real_pitch(pitch: byte; dir: Tdir; coord: byte): byte;
begin
  case pitch of
    1:  
      case dir of
        x_up: result := 4 + 2 * coord;
        y_down: result := 4 + 2 * coord ;
      end;
    2:
      case dir of
        x_up: result := 59 + 2 * coord;
        y_down: result := 4 + 2 * coord;
      end;
  end;
end;

function check_sybol(point: t_point): char;
var
  line_coord: t_line_coord;
begin
  line_coord := translate_coords(point);
  if line_coord in pc_ships.beaten_coord.kill then Result := 'X'
  else if line_coord in pc_ships.beaten_coord.missed then Result := '*'
  else Result := ' ';
end;

procedure darw_cursor(pitch: byte; point: t_point; c: char);
begin
  TextBackground(Yellow);
  GotoXY(translate_coords_on_real_pitch(pitch, x_up, point.x), translate_coords_on_real_pitch(pitch, y_down, point.y));
  Write(c);
  GotoXY(translate_coords_on_real_pitch(pitch, x_up, point.x), translate_coords_on_real_pitch(pitch, y_down, point.y));
end;

procedure clear_cursor(pitch: byte; point: t_point; c: char);
begin
  case pitch of
    1: 
      if translate_coords(point) in my_ships.area_coord then textBackground(Red)
      else TextBackground(Green);
    2: 
      if c = 'X' then TextBackground(12)
      else TextBackground(Green);
  end;
  GotoXY(translate_coords_on_real_pitch(pitch, x_up, point.x), translate_coords_on_real_pitch(pitch, y_down, point.y));
  case pitch of
    1:
      if my_ships.pitch[point.x, point.y] <> 0 then write('█')
      else Write(c);
    2: Write(c);
  end;
  GotoXY(translate_coords_on_real_pitch(pitch, x_up, point.x), translate_coords_on_real_pitch(pitch, y_down, point.y));
  TextBackground(Green);
end;

function up_coord(point: t_point): t_point;
begin
  if point.y <> 0 then Dec(point.y);
  Result := point;
end;

function down_coord(point: t_point): t_point;
begin
  if point.y <> 9 then Inc(point.y);
  Result := point;
end;

function right_coord(point: t_point): t_point;
begin
  if point.x <> 9 then Inc(point.x);
  Result := point;
end;

function left_coord(point: t_point): t_point;
begin
  if point.x <> 0 then Dec(point.x);
  Result := point;
end;


procedure draw_one_ship(regiter_ship_: boolean);
var
  c: char;
  set_: t_set_line_coord;
begin
  set_ := [];
  repeat
    infor_of_point.player.number := 7 + Random(4);
  until not (infor_of_point.player.number in infor_of_point.player.set_numder_of_ship);
  my_ships.ships[infor_of_point.player.number].dir := infor_of_point.player.dir;
  if is_right_coords(my_ships, infor_of_point.player.number) then
  begin
    Inc(infor_of_point.player.count);
    GotoXY(translate_coords_on_real_pitch(1, x_up, infor_of_point.player.point.x), translate_coords_on_real_pitch(1, y_down, infor_of_point.player.point.y));
    Write('█');
    write_count_ships;
    if regiter_ship_ then regiter_ship(infor_of_point.player.number, my_ships, set_, true);
    Include(infor_of_point.player.set_numder_of_ship, infor_of_point.player.number);
  end
                      else
  begin
    TextBackground(Green);
    TextColor(Red);
    GotoXY(1, 25);
    Write('нельзя разместить корабль               ');
    TextColor(Black);
  end;
  darw_cursor(1, infor_of_point.player.point, ' ');
end;

procedure draw_two_ship(regiter_ship_: boolean);
var
  set_: t_set_line_coord;
  i: byte;
  point: t_point;
begin
  point.x := 0;
  point.y := 0;
  set_ := [];
  repeat
    infor_of_point.player.number := 4 + Random(3);
  until not (infor_of_point.player.number in infor_of_point.player.set_numder_of_ship);
  my_ships.ships[infor_of_point.player.number].coord := infor_of_point.player.point;
  my_ships.ships[infor_of_point.player.number].dir := infor_of_point.player.dir;
  if  is_right_coords(my_ships, infor_of_point.player.number) then 
  begin
    if regiter_ship_ then regiter_ship(infor_of_point.player.number, my_ships, set_, true);
    for i := 0 to 1 do
    begin
      GotoXY(translate_coords_on_real_pitch(1, x_up, infor_of_point.player.point.x + point.x), translate_coords_on_real_pitch(1, y_down, infor_of_point.player.point.y + point.y));
      Write('█');
      case infor_of_point.player.dir of
        x_up: inc(point.x);
        x_down: dec(point.x);
        y_down: inc(point.y);
        y_up: dec(point.y);
      end;
    end;
    Include(infor_of_point.player.set_numder_of_ship, infor_of_point.player.number);
    Inc(infor_of_point.player.count);
    write_count_ships;
  end
  else 
  begin
    TextBackground(Green);
    TextColor(Red);
    GotoXY(1, 24);
    Write('нельзя разместить корабль               ');
    TextColor(Black);
  end;
  darw_cursor(1, infor_of_point.player.point, ' ');
end;

procedure draw_tree_ship(regiter_ship_: boolean);
var
  i: byte;
  point: t_point;
  set_: t_set_line_coord;
begin
  point.x := 0;
  point.y := 0;
  set_ := [];
  repeat
    infor_of_point.player.number := 2 + Random(2);
  until not (infor_of_point.player.number in infor_of_point.player.set_numder_of_ship);
  my_ships.ships[infor_of_point.player.number].coord := infor_of_point.player.point;
  my_ships.ships[infor_of_point.player.number].dir := infor_of_point.player.dir;
  if  is_right_coords(my_ships, infor_of_point.player.number) then 
  begin
    if regiter_ship_ then regiter_ship(infor_of_point.player.number, my_ships, set_, true);
    for i := 0 to 2 do
    begin
      GotoXY(translate_coords_on_real_pitch(1, x_up, infor_of_point.player.point.x + point.x), translate_coords_on_real_pitch(1, y_down, infor_of_point.player.point.y + point.y));
      Write('█');
      Delay(2000);
      case infor_of_point.player.dir of
        x_up: inc(point.x);
        x_down: dec(point.x);
        y_down: inc(point.y);
        y_up: dec(point.y);
      end;
    end;
    Include(infor_of_point.player.set_numder_of_ship, infor_of_point.player.number);
    Inc(infor_of_point.player.count);
    write_count_ships;
  end
  else 
  begin
    TextBackground(Green);
    TextColor(Red);
    GotoXY(1, 25);
    Write('нельзя разместить корабль               ');
    TextColor(Black);
  end;
  darw_cursor(1, infor_of_point.player.point, ' ');
end;


procedure draw_four_ship(regiter_ship_: boolean);
var
  i: byte;
  point: t_point;
  set_: t_set_line_coord;
begin
  point.x := 0;
  point.y := 0;
  set_ := [];
  repeat
    infor_of_point.player.number := 1 + Random(1);
  until not (infor_of_point.player.number in infor_of_point.player.set_numder_of_ship);
  my_ships.ships[infor_of_point.player.number].coord := infor_of_point.player.point;
  my_ships.ships[infor_of_point.player.number].dir := infor_of_point.player.dir;
  if  is_right_coords(my_ships, infor_of_point.player.number) then 
  begin
    if regiter_ship_ then regiter_ship(infor_of_point.player.number, my_ships, set_, true);
    for i := 0 to 3 do
    begin
      GotoXY(translate_coords_on_real_pitch(1, x_up, infor_of_point.player.point.x + point.x), translate_coords_on_real_pitch(1, y_down, infor_of_point.player.point.y + point.y));
      Write('█');
      case infor_of_point.player.dir of
        x_up: inc(point.x);
        x_down: dec(point.x);
        y_down: inc(point.y);
        y_up: dec(point.y);
      end;
    end;
    Include(infor_of_point.player.set_numder_of_ship, infor_of_point.player.number);
    Inc(infor_of_point.player.count);
    write_count_ships;
  end
  else 
  begin
    TextBackground(Green);
    TextColor(Red);
    GotoXY(1, 25);
    Write('нельзя разместить корабль               ');
    TextColor(Black);
  end;
  darw_cursor(1, infor_of_point.player.point, ' ');
end;

procedure delate_ship;
var
  set_: t_set_line_coord;
  i: byte;
  x, y: byte;
  point: t_point;
begin
  Dec(infor_of_point.player.count);
  write_count_ships;
  infor_of_point.player.number := my_ships.pitch[infor_of_point.player.point.x, infor_of_point.player.point.y];
  Exclude(infor_of_point.player.set_numder_of_ship, infor_of_point.player.number);
  regiter_ship(infor_of_point.player.number, my_ships, set_, false);
  my_ships.area_coord := my_ships.area_coord - set_; 
  for x := 0 to 9 do
    for y := 0 to 9 do
    begin
      point.x := x;
      point.y := y;
      TextBackground(2);
      if translate_coords(point) in set_ then 
      begin
        GotoXY(translate_coords_on_real_pitch(1, x_up, point.x), translate_coords_on_real_pitch(1, y_down, point.y));
        Write(' ');
        if my_ships.pitch[point.x, point.y] = infor_of_point.player.number then my_ships.pitch[point.x, point.y] := 0; 
      end;
      TextBackground(2);
    end;
  for i := 1 to 10 do
    if i in infor_of_point.player.set_numder_of_ship then regiter_ship(i, my_ships, set_, true);
  show_ships(0);
end;


function position(pitch: byte): t_point;
var
  isExit: boolean;
  key: TKey;
  c: char;
  set_player_point: t_set_line_coord;
  i: byte;
begin
  isExit := false;
  set_player_point := pc_ships.beaten_coord.missed + pc_ships.beaten_coord.kill;
  repeat
    c := check_sybol(infor_of_point.player.point);
    darw_cursor(pitch, infor_of_point.player.point, c);
    repeat
      key := getkey(false);
    until  key in [kDoun, kUp, kRight, kLeft, kEnter, kEsc];
    case key of
      kUp:  
        begin
          clear_cursor(pitch, infor_of_point.player.point, c);
          infor_of_point.player.point := up_coord(infor_of_point.player.point);
          if pitch = 1 then
          begin
            TextBackground(Green);
            GotoXY(1, 25);
            Write('                                        ');
          end;
        end;
      kDoun: 
        begin
          clear_cursor(pitch, infor_of_point.player.point, c);
          infor_of_point.player.point := down_coord(infor_of_point.player.point);
          if pitch = 1 then
          begin
            TextBackground(Green);
            GotoXY(1, 25);
            Write('                                        ');
          end;
        end;
      kRight: 
        begin
          clear_cursor(pitch, infor_of_point.player.point, c);
          infor_of_point.player.point := right_coord(infor_of_point.player.point);
          if pitch = 1 then
          begin
            TextBackground(Green);
            GotoXY(1, 25);
            Write('                                        ');
          end;
        end;
      kLeft: 
        begin
          clear_cursor(pitch, infor_of_point.player.point, c);
          infor_of_point.player.point := left_coord(infor_of_point.player.point);
          if pitch = 1 then
          begin
            TextBackground(Green);
            GotoXY(1, 25);
            Write('                                        ');
          end;
        end;
      kEnter: isExit := true;
      kEsc:
        begin
          case pitch of
            1:
              begin
                infor_of_point.player.cursor.draw_ship := false;
                infor_of_point.player.cursor.change_dir := false;
                infor_of_point.player.cursor.delate := false;
                isExit := true;
                if pitch = 1 then
                begin
                  TextBackground(Green);
                  GotoXY(1, 25);
                  Write('                                        ');
                end;
              end;
            2:
              begin
                clear_area(25, 11, 55, 21);
                initMenu_question2;
                show_question_menu2;
                runMenu_question2;
              end;
          end;
          if stop_game then Exit;
        end;
    end;
  until isExit;
  Result := infor_of_point.player.point;
end;

procedure regiter_area_kill_ship(i: byte; var ships: t_ships);
var
  k, j: byte;
  buf, point: t_point;
  dir: Tdir;
begin
  point.x := ships.ships[i].coord.x - 1;
  point.y := ships.ships[i].coord.y - 1;
  dir := ships.ships[i].dir;
  case dir of
    x_down: 
      begin
        point.x := ships.ships[i].coord.x - (ships.ships[i].Length - 1) - 1;
        dir := x_up
      end;
    y_up: 
      begin
        point.y := ships.ships[i].coord.y - (ships.ships[i].Length - 1) - 1;
        dir := y_down;
      end;
  end;
  buf.x := point.x;
  buf.y := point.y;
  case dir of
    x_up: 
      begin
        for k := 0 to 2 do
        begin
          point.y := buf.y;
          point.y := point.y + k;
          for j := 0 to ships.ships[i].Length + 1 do
          begin
            point.x := buf.x;
            point.x := point.x + j;
            if point_in_pitch(point) then Include(ships.beaten_coord.missed, translate_coords(point));
          end;
        end;
      end;
    y_down:
      begin
        for k := 0 to 2 do
        begin
          point.x := buf.x;
          point.x := point.x + k;
          for j := 0 to ships.ships[i].Length + 1 do
          begin
            point.y := buf.y;
            point.y := point.y + j;
            if point_in_pitch(point) then Include(ships.beaten_coord.missed, translate_coords(point));
          end;
        end;
      end;
  end;
  ships.beaten_coord.missed := ships.beaten_coord.missed - (ships.beaten_coord.kill * ships.beaten_coord.missed);
end;

procedure regiter_kill_ship(i: byte; var ships: t_ships);
begin
  case i of
    1: dec(ships.kill_ships.four);
    2..3: dec(ships.kill_ships.three);
    4..6: dec(ships.kill_ships.two);
    7..10: dec(ships.kill_ships.one);
  end;
  regiter_area_kill_ship(i, ships);
  draw_display_information;
end;


procedure register_kill_part_ship(pitch: byte; i: byte; point: t_point; var ships: t_ships);
begin
  inc(ships.ships[i].beaten);
  GotoXY(translate_coords_on_real_pitch(pitch, x_up, point.x), translate_coords_on_real_pitch(pitch, y_down, point.y));
  TextBackground(12);
  Write('X');
  TextBackground(2);
  Include(ships.beaten_coord.kill, translate_coords(point));
  case pitch of
    1:
      begin
        kill_part_ship.player := true;
        Delay(1500);
      end;
    2: kill_part_ship.pc := true;
  end;
  if ships.ships[i].beaten = ships.ships[i].Length then
  begin
    regiter_kill_ship(i, ships);
    case pitch of
      1: kill_ship.player := true;
      2: kill_ship.pc := true;
    end;
  end;
end;

procedure register_missed(pitch: byte; point: t_point; var ships: t_ships);
begin
  case pitch of
    1: 
      begin
        infor_of_point.pc.buf_point := point;
        TextColor(13);
        kill_ship.player := false;
        kill_part_ship.player := false;
      end;
    2: 
      begin
        TextColor(0);
        kill_ship.pc := false;
        kill_part_ship.pc := false;
        TextBackground(2);
        GotoXY(translate_coords_on_real_pitch(1, x_up, infor_of_point.pc.buf_point.x), translate_coords_on_real_pitch(1, y_down, infor_of_point.pc.buf_point.y));
        Write('*');
        TextBackground(Yellow);
      end;
  end;
  GotoXY(translate_coords_on_real_pitch(pitch, x_up, point.x), translate_coords_on_real_pitch(pitch, y_down, point.y));
  Write('*');
  TextColor(0);
  Include(ships.beaten_coord.missed, translate_coords(point));
  draw_display_information;
end;

procedure check_position(pitch: byte; point: t_point; var ships: t_ships);
var
  ship: byte;
begin
  ship := ships.pitch[point.x, point.y];
  case ship of
    1: register_kill_part_ship(pitch, 1, point, ships); 
    2: register_kill_part_ship(pitch, 2, point, ships); 
    3: register_kill_part_ship(pitch, 3, point, ships); 
    4: register_kill_part_ship(pitch, 4, point, ships); 
    5: register_kill_part_ship(pitch, 5, point, ships); 
    6: register_kill_part_ship(pitch, 6, point, ships); 
    7: register_kill_part_ship(pitch, 7, point, ships); 
    8: register_kill_part_ship(pitch, 8, point, ships); 
    9: register_kill_part_ship(pitch, 9, point, ships); 
    10: register_kill_part_ship(pitch, 10, point, ships);
  else register_missed(pitch, point, ships);
  end;
end;

function sum_beaten_ships(ships: t_ships): byte;
begin
  Result := ships.kill_ships.four + ships.kill_ships.three + ships.kill_ships.two + ships.kill_ships.one; 
end;

procedure draw_missed;
var
  x, y: byte;
begin
  for x := 0 to 9 do
    for y := 0 to 9 do
    begin
      if ((y * 10) + x) in pc_ships.beaten_coord.missed then 
      begin
        GotoXY(translate_coords_on_real_pitch(2, x_up, x), translate_coords_on_real_pitch(2, y_down, y));
        Write('*');
      end;
    end;
end;

procedure draw_run_player;
begin
  TextBackground(12);
  GotoXY(41, 4);
  Write('              ');
  TextBackground(Green);
  GotoXY(26, 4);
  Write('              ');
  GotoXY(41, 4);
end;

procedure draw_run_pc;
begin
  TextBackground(12);
  GotoXY(26, 4);
  Write('              ');
  TextBackground(Green);
  GotoXY(41, 4);
  Write('              ');
  GotoXY(26, 4);
end;

procedure draw_display_information;
begin
  TextBackground(Green);
  GotoXY(38, 9);
  Write(new_record.score);
  GotoXY(33, 14);
  Write('     ', my_ships.kill_ships.one);
  GotoXY(45, 14);
  Write('     ', pc_ships.kill_ships.one);
  GotoXY(33, 16);
  Write('     ', my_ships.kill_ships.two);
  GotoXY(45, 16);
  Write('     ', pc_ships.kill_ships.two);
  GotoXY(33, 18);
  Write('     ', my_ships.kill_ships.three);
  GotoXY(45, 18);
  Write('     ', pc_ships.kill_ships.three);
  GotoXY(33, 20);
  Write('     ', my_ships.kill_ships.four);
  GotoXY(45, 20);
  Write('     ', pc_ships.kill_ships.four);
end;

procedure run_player;
var
  player_point: t_point;
begin
  draw_run_player;
  Inc(new_record.score);
  repeat
    player_point := position(2);
    if stop_game then Exit;
    check_position(2, player_point, pc_ships);
    if kill_ship.pc then draw_missed;
  until (not kill_part_ship.pc) or (sum_beaten_ships(pc_ships) = 0);
end;

function random_pc_point: t_point;
var
  set_pc_line_coord: t_set_line_coord;
  pc_point: t_point;
begin
  set_pc_line_coord := my_ships.beaten_coord.missed + my_ships.beaten_coord.kill;
  repeat
    pc_point := random_point;
  until not (translate_coords(pc_point) in set_pc_line_coord);
  Result := pc_point;
end;

procedure kill_ships;
var
  i: byte;
  namber: byte;
begin
  namber := my_ships.pitch[infor_of_point.pc.point.x, infor_of_point.pc.point.y];
  infor_of_point.pc.point := my_ships.ships[namber].coord;
  for i := 1 to my_ships.ships[namber].Length do
  begin
    check_position(1, infor_of_point.pc.point, my_ships);
    case my_ships.ships[namber].dir of
      x_up: inc(infor_of_point.pc.point.x);
      x_down: dec(infor_of_point.pc.point.x);
      y_down: inc(infor_of_point.pc.point.y);
      y_up: dec(infor_of_point.pc.point.y);
    end;
  end;
end;

procedure run_pc;
var
  b: boolean;
begin
  draw_run_pc;
  Delay(1000);
  repeat
    b := true;
    infor_of_point.pc.point := random_pc_point;
    if my_ships.pitch[infor_of_point.pc.point.x, infor_of_point.pc.point.y] = 0 then check_position(1, infor_of_point.pc.point, my_ships)
    else
    begin
      kill_ships;
      b := false;
    end;
  until b or (sum_beaten_ships(my_ships) = 0);
end;


procedure draw_display;
begin
  GotoXY(25, 1);
  Write('╔══════════════╦══════════════╗');
  GotoXY(25, 2);
  Write('║                             ║');
  GotoXY(26, 2);
  TextColor(Yellow);
  Write('ход копьютера    ход игрока  ');
  TextColor(0);
  GotoXY(40, 2);
  Write('║');
  GotoXY(25, 3);
  Write('╠══════════════╬══════════════╣');
  GotoXY(25, 4);
  Write('║              ║              ║');
  GotoXY(25, 5);
  Write('╚══════════════╩══════════════╝');
  GotoXY(34, 6);
  Write('╔═══════════╗');
  GotoXY(34, 7);
  Write('║           ║');
  GotoXY(38, 7);
  TextColor(Yellow);
  Write('ходы');
  TextColor(0);
  GotoXY(34, 8);
  Write('╠═══════════╣');
  GotoXY(34, 9);
  Write('║   0       ║');
  GotoXY(34, 10);
  Write('╚═══════════╝');
  GotoXY(25, 11);
  Write('╔══════╦═══════════╦══════════╗');
  GotoXY(25, 12);
  Write('║      ║           ║          ║');
  GotoXY(26, 12);
  TextColor(Yellow);
  Write('палубы');
  GotoXY(33, 12);
  Write('корабли мои');
  GotoXY(45, 12);
  Write('корабли ПК');
  TextColor(0);
  GotoXY(25, 13);
  Write('╠══════╬═══════════╬══════════╣');
  GotoXY(25, 14);
  Write('║  1   ║     4     ║     4    ║');
  GotoXY(25, 15);
  Write('╠══════╬═══════════╬══════════╣');
  GotoXY(25, 16);
  Write('║  2   ║     3     ║     3    ║');
  GotoXY(25, 17);
  Write('╠══════╬═══════════╬══════════╣');
  GotoXY(25, 18);
  Write('║  3   ║     2     ║     2    ║');
  GotoXY(25, 19);
  Write('╠══════╬═══════════╬══════════╣');
  GotoXY(25, 20);
  Write('║  4   ║     1     ║     1    ║');
  GotoXY(25, 21);
  Write('╚══════╩═══════════╩══════════╝');
end;

procedure player_run_game;
begin
  restart_game := false;
  Background;
  show_game_pitch_1;
  show_game_pitch_2;
  show_ships(Black);
  draw_display;
  infor_of_point.player.point.x := 0;
  infor_of_point.player.point.y := 0;
  repeat
    run_pc;
    if sum_beaten_ships(my_ships) > 0 then run_player;
    if stop_game then Exit;
  until (sum_beaten_ships(pc_ships) = 0) or (sum_beaten_ships(my_ships) = 0);
  Delay(1000);
  end_game;
end;

procedure option_game;
begin
  stop_game := false;
  clear_cache(my_ships);
  clear_cache(pc_ships);
  repeat
    restart_game := false;
    Background;
    show_game_pitch_1;
    GotoXY(50, 1);
    Write('╔════════════════════╗');
    GotoXY(50, 2);
    Write('║Расстановка кораблей║');
    GotoXY(50, 3);
    Write('╚════════════════════╝');
    GotoXY(45, 4);
    write('█');
    GotoXY(45, 6);
    write('█ ,█ █ █ █ - четырёхпалубный корабль  ');
    GotoXY(45, 8);
    write('█');
    GotoXY(45, 10);
    write('█');
    GotoXY(45, 12);
    write('        █');
    GotoXY(45, 14);
    write('█ █ █ , █ - трёхпалубный корабль');
    GotoXY(45, 16);
    write('        █');
    GotoXY(45, 18);
    write('█');
    GotoXY(45, 20);
    write('█ , █ █ - двухпалубный корабль');
    GotoXY(45, 24);
    write('█ - однопалубный корабль');
    init_ships_base(my_ships);
    infor_of_point.player.point.x := 0;
    infor_of_point.player.point.y := 0;
    infor_of_point.player.set_numder_of_ship := [];
    initMenu_option;
    showMenu_option;
    runMenu_option;
    clear_cache(my_ships);
    if stop_game then Exit;
  until not (restart_game);
end;

procedure initMenu_question;
var
  i: byte;
begin
  textcolor(Black);
  for i := 0 to 1 do
    mainMenu_question.Items[i, 0] := ramka_up_question;
  for i := 0 to 1 do
    mainMenu_question.Items[i, 2] := ramka_down_question;
  mainMenu_question.Items[0, 1] := '║ да  ║';
  mainMenu_question.Items[1, 1] := '║ нет ║';  
  mainMenu_question.activeItem := 0;
end;

procedure nextItem_question;
begin
  if   mainMenu_question.activeItem = 1 then
    mainMenu_question.activeItem := 0
  else inc(  mainMenu_question.activeItem);
end;

procedure prevItem_question;
begin
  if   mainMenu_question.activeItem = 0 then
    mainMenu_question.activeItem := 1
  else dec(  mainMenu_question.activeItem);
end;

procedure show_question_menu;
var
  posMenu: t_point;
  i, j: byte;
begin
  posMenu.y := 20;
  posMenu.x := 32;
  for i := 0 to 1 do
  begin
    if i = mainMenu_question.activeitem then
      textBackground(13)
    else  textBackground(Yellow);
    for j := 0 to 2 do
    begin
      gotoXY(posMenu.x, posMenu.y);
      Write(mainMenu_question.items[i, j]);
      Inc(PosMenu.y); 
    end;
    PosMenu.y := PosMenu.y - 3;
    posMenu.x := posMenu.x + 12;
  end;
  textBackground(2);
end;

procedure runMenu_question;
var
  key: TKey;
  isExit_question: boolean;
begin
  isExit_question := false;
  repeat
    key := getkey(false);
    if key in [kRight, kLeft, kEnter] then
    begin
      case key of
        kLeft: prevItem_question;
        kRight: nextItem_question;
        kEnter:
          begin
            case mainMenu_question.activeItem of
              0: 
                begin
                  isExit_question := true;
                  restart_game := true;
                end;
              1: isExit_question := true;
            end; 
          end;
      end;
      show_question_menu;
    end;
  until isExit_question;
end;

procedure Read_record;
begin
  TextColor(Black);
  GotoXY(29, 20);
  repeat
  until getkey(true) = kEnter;
end;

procedure write_record;
var
  t1: file of Trecords;
  t2: Text;
  n, i: byte;
  mas: array of Trecords;
begin
  GotoXY(25, 18);
  TextColor(Yellow);
  write('      Введите своё имя');
  TextBackground(8);
  GotoXY(29, 20);
  write('                    ');
  i_symbol := 0;
  Read_record;
  assign(t1, 'game_records.iso');
  Reset(t1);
  n := FileSize(t1) + 1;
  SetLength(mas, n);
  mas[0] := new_record;
  for i := 1 to n - 1 do
    Read(t1, mas[i]);
  Close(t1);
  if n <> 1 then
  begin
    for i := 0 to n - 2 do
      if mas[i].score > mas[i + 1].score then Swap(mas[i + 1], mas[i]);
  end;  
  
  Rewrite(t1);
  Close(t1);
  Reset(t1);
  if n > 10 then Dec(n);
  for i := 0 to n - 1 do
    Write(t1, mas[i]);
  Close(t1);
  TextBackground(2);
  clear_area(25, 18, 47, 20);
end;

procedure clear_area(x1, y1, x2, y2: byte);
var
  i, j: byte;
begin
  TextBackground(2);
  for i := x1 to x2 do 
    for j := y1 to y2 do
    begin
      GotoXY(i, j);
      write(' ');
    end;
end;

procedure win_game;
begin
  TextBackground(12);
  GotoXY(30, 12);
  Write('╔═══════════════════╗');
  GotoXY(30, 13);
  Write('║                   ║');
  GotoXY(32, 13);
  TextColor(Yellow);
  Write('Вы выграли  ! ! !');
  TextColor(0);
  GotoXY(30, 14);
  Write('╚═══════════════════╝');
  TextBackground(2);
  GotoXY(30, 16);
  write_record;
end;

procedure lose_game;
begin
  TextBackground(12);
  GotoXY(30, 12);
  Write('╔═══════════════════╗');
  GotoXY(30, 13);
  Write('║                   ║');
  GotoXY(31, 13);
  TextColor(Yellow);
  Write('Вы проиграли  ! ! !');
  TextColor(0);
  GotoXY(30, 14);
  Write('╚═══════════════════╝');
  TextBackground(2);
end;

procedure question;
begin
  GotoXY(26, 16);
  TextBackground(2);
  TextColor(Yellow);
  Write('Хотие ли вы съиграть ещё раз ?');
  TextColor(0);
  initMenu_question;
  show_question_menu;
  runMenu_question;
end;

procedure end_game;
var
  i, j: byte;
begin
  clear_area(25, 11, 55, 21);
  if sum_beaten_ships(pc_ships) = 0 then win_game
  else lose_game;
  question;
  clear_cache(pc_ships);
  clear_cache(my_ships); 
end;

procedure initMenu_option;
var
  i: byte;
begin
  textcolor(Black);
  for i := 0 to 3 do
    mainMenu_option.Items[i, 0] := ramka_up_option;
  for i := 0 to 3 do
    mainMenu_option.Items[i, 2] := ramka_down_option;
  mainMenu_option.Items[0, 1] := '║      играть      ║';
  mainMenu_option.Items[1, 1] := '║ авто расстановка ║';  
  mainMenu_option.Items[2, 1] := '║ручная расстановка║';
  mainMenu_option.Items[3, 1] := '║      выход       ║';
  mainMenu_option.activeItem := 0;
end;

procedure nextItem_option;
begin
  if   mainMenu_option.activeItem = 3 then
    mainMenu_option.activeItem := 0
  else inc(  mainMenu_option.activeItem);
end;

procedure prevItem_option;
begin
  if   mainMenu_option.activeItem = 0 then
    mainMenu_option.activeItem := 3
  else dec(  mainMenu_option.activeItem);
end;

procedure showMenu_option;
var
  posMenu, i, j: byte;
begin
  posMenu := 5;
  for i := 0 to 3 do
  begin
    if i = mainMenu_option.activeitem then
      textBackground(13)
    else  textBackground(Yellow);
    for j := 0 to 2 do
    begin
      gotoXY(24, posMenu);
      Write(mainMenu_option.items[i, j]);
      Inc(PosMenu); 
    end;
    PosMenu := PosMenu + 2;
  end;
  textBackground(0);
end;

procedure exit_to_menu;
begin
  clear_cache(pc_ships);
  clear_cache(my_ships);
  isExit_option := true;
end;

procedure show_not_position(check: boolean);
var
  color, x, y: byte;
  point: t_point;
begin
  if check then color := 4
  else color := 2;
  for x := 0 to 9 do
    for y := 0 to 9 do
    begin
      point.x := x;
      point.y := y;
      if translate_coords(point) in my_ships.area_coord then
      begin
        GotoXY(translate_coords_on_real_pitch(1, x_up, point.x), translate_coords_on_real_pitch(1, y_down, point.y));
        TextBackground(color);
        if my_ships.pitch[x, y] <> 0 then Write('█')
        else write(' ');
        TextBackground(2);
      end;
    end;
end;

procedure write_count_ships;
begin
  TextBackground(2);
  TextColor(Red);
  GotoXY(44, 25);
  Write('осталось расставить');
  GotoXY(68, 25);
  Write('кораблей');
  GotoXY(65, 25);
  if infor_of_point.player.count = 0 then Write(10 - infor_of_point.player.count)
  else write(' ', 10 - infor_of_point.player.count);
  TextColor(Black);
end;

procedure delate_cursor;
var
  c: char;
begin
  c := ' ';
  clear_cursor(1, infor_of_point.player.point, c);
  if my_ships.pitch[infor_of_point.player.point.x, infor_of_point.player.point.y] = 0 then 
  begin
    TextBackground(2);
    GotoXY(translate_coords_on_real_pitch(1, x_up, infor_of_point.player.point.x), translate_coords_on_real_pitch(1, y_down, infor_of_point.player.point.y));
    Write(c);
  end;
end;


procedure initMenu_variant_of_dir;
var
  i: byte;
begin
  textcolor(Black);
  for i := 0 to 4 do
  begin
    mainMenu_variant_of_dir.Items[i, 0] := ramka_up_option;
    mainMenu_variant_of_dir.Items[i, 2] := ramka_down_option;
  end;
  mainMenu_variant_of_dir.Items[0, 1] := '║      вверх       ║';
  mainMenu_variant_of_dir.Items[1, 1] := '║      вниз        ║';  
  mainMenu_variant_of_dir.Items[2, 1] := '║      влево       ║';
  mainMenu_variant_of_dir.Items[3, 1] := '║      вправо      ║';
  mainMenu_variant_of_dir.Items[4, 1] := '║  вернуться назат ║';
  mainMenu_variant_of_dir.activeItem := 0;
end;

procedure nextItem_variant_of_dir;
begin
  if   mainMenu_variant_of_dir.activeItem = 4 then
    mainMenu_variant_of_dir.activeItem := 0
  else inc(mainMenu_variant_of_dir.activeItem);
  TextBackground(Green);
  GotoXY(1, 25);
  Write('                                        ');
end;

procedure prevItem_variant_of_dir;
begin
  if   mainMenu_variant_of_dir.activeItem = 0 then
    mainMenu_variant_of_dir.activeItem := 4
  else dec(mainMenu_variant_of_dir.activeItem);
  TextBackground(Green);
  GotoXY(1, 25);
  Write('                                        ');
end;

procedure showMenu_variant_of_dir;
var
  posMenu, i, j: byte;
begin
  posMenu := 4;
  for i := 0 to 4 do
  begin
    if i = mainMenu_variant_of_dir.activeitem then
      textBackground(13)
    else  textBackground(Yellow);
    for j := 0 to 2 do
    begin
      gotoXY(24, posMenu);
      Write(mainMenu_variant_of_dir.items[i, j]);
      Inc(PosMenu); 
    end;
    PosMenu := PosMenu + 1;
  end;
  textBackground(0);
end;

procedure runMenu_variant_of_dir;
var
  key: TKey;
  my_init_ships: boolean;
  isExit: boolean;
  set_: t_set_line_coord;
begin
  isExit := false;
  repeat
    key := getkey(false);
    if key in [kDoun, kUp, kEnter] then
    begin
      case key of
        kUp: prevItem_variant_of_dir;
        kDoun: nextItem_variant_of_dir;
        kEnter:
          begin
            TextBackground(Green);
            GotoXY(1, 25);
            Write('                                        ');
            case mainMenu_variant_of_dir.activeItem of
              0: 
                begin
                  infor_of_point.player.dir := y_up;
                  isExit := true;
                end;
              1: 
                begin
                  infor_of_point.player.dir := y_down;
                  isExit := true;
                end;
              2: 
                begin
                  infor_of_point.player.dir := x_down;
                  isExit := true;
                end;
              3: 
                begin
                  infor_of_point.player.dir := x_up;
                  isExit := true;
                end;
              4: 
                begin
                  infor_of_point.player.dir := dir_note;
                  isExit := true;
                end;
            end;
          end;
      end;
      showMenu_variant_of_dir;
    end;
  until isExit;
  case infor_of_point.player.Length of
    2: draw_two_ship(true);
    3: draw_tree_ship(true);
    4: draw_four_ship(true);
  end;
  infor_of_point.player.Length := 0;
  clear_area(24, 4, 43, 23);
end;

procedure initMenu_variant_of_ships;
var
  i: byte;
begin
  textcolor(Black);
  for i := 0 to 5 do
  begin
    mainMenu_variant_of_ships.Items[i, 0] := ramka_up_option;
    mainMenu_variant_of_ships.Items[i, 2] := ramka_down_option;
  end;
  mainMenu_variant_of_ships.Items[0, 1] := '║   однопалубный   ║';
  mainMenu_variant_of_ships.Items[1, 1] := '║   двухпалубный   ║';  
  mainMenu_variant_of_ships.Items[2, 1] := '║   трехпалубный   ║';
  mainMenu_variant_of_ships.Items[3, 1] := '║ четырехпалубный  ║';
  mainMenu_variant_of_ships.Items[4, 1] := '║переставить курсор║';
  mainMenu_variant_of_ships.Items[5, 1] := '║  вернуться назат ║';
  mainMenu_variant_of_ships.activeItem := 0;
end;

procedure nextItem_variant_of_ships;
begin
  if   mainMenu_variant_of_ships.activeItem = 5 then
    mainMenu_variant_of_ships.activeItem := 0
  else inc(  mainMenu_variant_of_ships.activeItem);
  TextBackground(Green);
  GotoXY(1, 25);
  Write('                                        ');
end;

procedure prevItem_variant_of_ships;
begin
  if   mainMenu_variant_of_ships.activeItem = 0 then
    mainMenu_variant_of_ships.activeItem := 5
  else dec(mainMenu_variant_of_ships.activeItem);
  TextBackground(Green);
  GotoXY(1, 25);
  Write('                                        ');
end;

procedure showMenu_variant_of_ships;
var
  posMenu, i, j: byte;
begin
  posMenu := 2;
  for i := 0 to 5 do
  begin
    if i = mainMenu_variant_of_ships.activeitem then
      textBackground(13)
    else  textBackground(Yellow);
    for j := 0 to 2 do
    begin
      gotoXY(24, posMenu);
      Write(mainMenu_variant_of_ships.items[i, j]);
      Inc(PosMenu); 
    end;
    PosMenu := PosMenu + 1;
  end;
  textBackground(0);
end;

procedure runMenu_variant_of_ships;
var
  i: byte;
  set_: t_set_line_coord;
  point: t_point;
  key: TKey;
  my_init_ships: boolean;
  isExit: boolean;
begin
  isExit := false;
  mainMenu_variant_of_ships.activeitem := 0;
  point := position(1);
  if infor_of_point.player.cursor.draw_ship then
  begin
    showMenu_variant_of_ships;
    repeat
      key := getkey(false);
      if key in [kDoun, kUp, kEnter] then
      begin
        case key of
          kUp: prevItem_variant_of_ships;
          kDoun: nextItem_variant_of_ships;
          kEnter:
            begin
              TextBackground(Green);
              GotoXY(1, 25);
              Write('                                        ');
              i := 0;
              case mainMenu_variant_of_ships.activeItem of
                0: 
                  begin
                    if 7 in infor_of_point.player.set_numder_of_ship then Inc(i);
                    if 8 in infor_of_point.player.set_numder_of_ship then Inc(i);
                    if 9 in infor_of_point.player.set_numder_of_ship then Inc(i);
                    if 10 in infor_of_point.player.set_numder_of_ship then Inc(i);
                    if i < 4 then draw_one_ship(true)
                       else
                    begin
                      TextBackground(Green);
                      TextColor(Red);
                      GotoXY(1, 25);
                      Write('все однопалубные корабли расставленны   ');
                      TextColor(Black);
                    end;
                  end;
                1: 
                  begin
                    if 4 in infor_of_point.player.set_numder_of_ship then Inc(i);
                    if 5 in infor_of_point.player.set_numder_of_ship then Inc(i);
                    if 6 in infor_of_point.player.set_numder_of_ship then Inc(i);
                    if i < 3 then
                    begin
                      clear_area(24, 2, 43, 24);
                      infor_of_point.player.Length := 2;
                      initMenu_variant_of_dir;
                      showMenu_variant_of_dir;
                      runMenu_variant_of_dir;
                    end
                    else
                    begin
                      TextBackground(Green);
                      TextColor(Red);
                      GotoXY(1, 25);
                      Write('все двухпалубные корабли расставленны   ');
                      TextColor(Black);
                    end;
                  end;
                2: 
                  begin
                    if 2 in infor_of_point.player.set_numder_of_ship then Inc(i);
                    if 3 in infor_of_point.player.set_numder_of_ship then Inc(i);
                    if i < 2 then
                    begin
                      clear_area(24, 2, 43, 24);
                      infor_of_point.player.Length := 3;
                      initMenu_variant_of_dir;
                      showMenu_variant_of_dir;
                      runMenu_variant_of_dir;
                    end
                    else
                    begin
                      TextBackground(Green);
                      TextColor(Red);
                      GotoXY(1, 25);
                      Write('все трехпалубные корабли расставленны   ');
                      TextColor(Black);
                    end;
                  end;
                3: 
                  begin
                    if 1 in infor_of_point.player.set_numder_of_ship then Inc(i);
                    if i < 1 then
                    begin
                      clear_area(24, 2, 43, 24);
                      infor_of_point.player.Length := 4;
                      initMenu_variant_of_dir;
                      showMenu_variant_of_dir;
                      runMenu_variant_of_dir;
                    end
                    else
                    begin
                      TextBackground(Green);
                      TextColor(Red);
                      GotoXY(1, 25);
                      Write('все четырехпалубные корабли расставленны');
                      TextColor(Black);
                    end;
                  end;
                4: 
                  begin
                    mainMenu_variant_of_ships.activeitem := 6;
                    showMenu_variant_of_ships;
                    point := position(1);
                    mainMenu_variant_of_ships.activeitem := 4;
                    showMenu_variant_of_ships;
                  end;
                5: isExit := true;
              end;
            end;
        end;
        showMenu_variant_of_ships;
      end;
    until isExit;
  end;
  delate_cursor;
  clear_area(24, 2, 43, 24);
  clear_area(43, 4, 80, 23);
  GotoXY(45, 4);
  write('█');
  GotoXY(45, 6);
  write('█ ,█ █ █ █ - четырёхпалубный корабль  ');
  GotoXY(45, 8);
  write('█');
  GotoXY(45, 10);
  write('█');
  GotoXY(45, 12);
  write('        █');
  GotoXY(45, 14);
  write('█ █ █ , █ - трёхпалубный корабль');
  GotoXY(45, 16);
  write('        █');
  GotoXY(45, 18);
  write('█');
  GotoXY(45, 20);
  write('█ , █ █ - двухпалубный корабль');
  GotoXY(45, 24);
  write('█ - однопалубный корабль');
end;

procedure initMenu_allocation;
var
  i: byte;
begin
  textcolor(Black);
  for i := 0 to 3 do
  begin
    mainMenu_allocation.Items[i, 0] := ramka_up_option;
    mainMenu_allocation.Items[i, 2] := ramka_down_option;
  end;
  mainMenu_allocation.Items[0, 1] := '║     поставить    ║';
  mainMenu_allocation.Items[1, 1] := '║      убрать      ║';  
  mainMenu_allocation.Items[2, 1] := '║      выход       ║';
  mainMenu_allocation.activeItem := 0;
end;

procedure nextItem_allocation;
begin
  if   mainMenu_allocation.activeItem = 2 then
    mainMenu_allocation.activeItem := 0
  else inc(mainMenu_allocation.activeItem);
  TextBackground(Green);
  GotoXY(1, 25);
  Write('                                        ');
end;

procedure prevItem_allocation;
begin
  if   mainMenu_allocation.activeItem = 0 then
    mainMenu_allocation.activeItem := 2
  else dec(mainMenu_allocation.activeItem);
  TextBackground(Green);
  GotoXY(1, 25);
  Write('                                        ');
end;

procedure showMenu_allocation;
var
  posMenu, i, j: byte;
begin
  posMenu := 7;
  for i := 0 to 2 do
  begin
    if i = mainMenu_allocation.activeitem then
      textBackground(13)
    else  textBackground(Yellow);
    for j := 0 to 2 do
    begin
      gotoXY(24, posMenu);
      Write(mainMenu_allocation.items[i, j]);
      Inc(PosMenu); 
    end;
    PosMenu := PosMenu + 3;
  end;
  textBackground(0);
end;

procedure runMenu_allocation;
var
  point: t_point;
  key: TKey;
  my_init_ships: boolean;
  isExit: boolean;
  i: byte;
begin
  isExit := false;
  repeat
    key := getkey(false);
    if key in [kDoun, kUp, kEnter] then
    begin
      case key of
        kUp: prevItem_allocation;
        kDoun: nextItem_allocation;
        kEnter:
          begin
            case mainMenu_allocation.activeItem of
              0: 
                begin
                  infor_of_point.player.cursor.draw_ship := true;
                  clear_area(24, 4, 80, 24);
                  GotoXY(44, 4);
                  Writeln('╔═══════════════════════════════════╗');
                  GotoXY(44, 5);
                  Writeln('║ Используйте стрелки что бы        ║');
                  GotoXY(44, 6);
                  Writeln('║                                   ║');
                  GotoXY(44, 7);
                  Writeln('║ переместить курсор. Если нажмете  ║');
                  GotoXY(44, 8);
                  Writeln('║                                   ║');
                  GotoXY(44, 9);
                  Writeln('║ Esc, то вы выйдите в предыдущее   ║');
                  GotoXY(44, 10);
                  Writeln('║                                   ║');
                  GotoXY(44, 11);
                  Writeln('║ меню. Если нажмете Enter, то      ║');
                  GotoXY(44, 12);
                  Writeln('║                                   ║');
                  GotoXY(44, 13);
                  Writeln('║ перейдете в меню на экране. Затем ║');
                  GotoXY(44, 14);
                  Writeln('║                                   ║');
                  GotoXY(44, 15);
                  Writeln('║ вы выберете корабль который       ║');
                  GotoXY(44, 16);
                  Writeln('║                                   ║');
                  GotoXY(44, 17);
                  Writeln('║ поставить. А потом вы выбираете   ║');
                  GotoXY(44, 18);
                  Writeln('║                                   ║');
                  GotoXY(44, 19);
                  Writeln('║ сторону в которую  надо рисовать  ║');
                  GotoXY(44, 20);
                  Writeln('║                                   ║');
                  GotoXY(44, 21);
                  Writeln('║ корабль.                          ║');
                  GotoXY(44, 22);
                  Writeln('║                                   ║');
                  GotoXY(44, 23);
                  Writeln('╚═══════════════════════════════════╝');
                  initMenu_variant_of_ships;
                  mainMenu_variant_of_ships.activeitem := 6;
                  showMenu_variant_of_ships;
                  runMenu_variant_of_ships;
                end;
              1: 
                begin
                  clear_area(44, 4, 80, 24);
                  GotoXY(44, 4);
                  Writeln('╔═══════════════════════════════════╗');
                  GotoXY(44, 5);
                  Writeln('║ Используйте стрелки что бы        ║');
                  GotoXY(44, 6);
                  Writeln('║                                   ║');
                  GotoXY(44, 7);
                  Writeln('║ переместить курсор. Если нажмете  ║');
                  GotoXY(44, 8);
                  Writeln('║                                   ║');
                  GotoXY(44, 9);
                  Writeln('║ Esc, то вы выйдите в предыдущее   ║');
                  GotoXY(44, 10);
                  Writeln('║                                   ║');
                  GotoXY(44, 11);
                  Writeln('║ меню. Если нажмете Enter, то      ║');
                  GotoXY(44, 12);
                  Writeln('║                                   ║');
                  GotoXY(44, 13);
                  Writeln('║ корабль на котором стоит курсор   ║');
                  GotoXY(44, 14);
                  Writeln('║                                   ║');
                  GotoXY(44, 15);
                  Writeln('║ будет удален.                     ║');
                  for i := 0 to 7 do
                  begin
                    GotoXY(44, 16 + i);
                    Writeln('║                                   ║');
                  end;
                  GotoXY(44, 23);
                  Writeln('╚═══════════════════════════════════╝');
                  infor_of_point.player.cursor.delate := true;
                  repeat
                    point := position(1);
                    if my_ships.pitch[point.x, point.y] = 0 then
                    begin
                      TextBackground(Green);
                      TextColor(Red);
                      GotoXY(1, 25);
                      Write('на этом месте нет корабля               ');
                      TextColor(Black);
                    end;
                    if (my_ships.pitch[point.x, point.y] <> 0) and infor_of_point.player.cursor.delate then 
                    begin
                      TextBackground(Green);
                      GotoXY(1, 25);
                      Write('                                        ');
                      delate_ship;
                    end;
                  until not (infor_of_point.player.cursor.delate);
                  TextBackground(Green);
                  GotoXY(1, 25);
                  Write('                                        ');
                  delate_cursor;
                end;
              2: isExit := true;
            end;
          end;
      end;
      showMenu_allocation;
    end;
  until isExit;
  clear_area(24, 4, 43, 23);
end;


procedure allocation_ships;
var
  c: char;
  point: t_point;
  key: TKey;
  y, x: byte;
begin
  init_ships_base(my_ships);
  show_not_position(true);
  clear_area(24, 2, 44, 23);
  initMenu_allocation;
  showMenu_allocation;
  runMenu_allocation;
  show_not_position(false);
  
  infor_of_point.player.point.x := 0;
  infor_of_point.player.point.x := 0;
  GotoXY(1, 25);
  Write('                                        ');
end;

procedure update_ships;
begin
  TextBackground(2);
  GotoXY(1, 24);
  Write('                                            ');
  show_ships(2);
  clear_cache(my_ships);
  init_ships_base(my_ships);
  init_ships_coords(my_ships);
  show_ships(0);
end;

procedure runMenu_option;
var
  key: TKey;
  my_init_ships: boolean;
begin
  
  isExit_option := false;
  my_init_ships := false;
  repeat
    key := getkey(false);
    if key in [kDoun, kUp, kEnter] then
    begin
      case key of
        kUp: prevItem_option;
        kDoun: nextItem_option;
        kEnter:
          begin
            case mainMenu_option.activeItem of
              0: 
                begin
                  if not (my_init_ships) then 
                  begin
                    TextBackground(Green);
                    TextColor(Red);
                    GotoXY(1, 24);
                    Write('вы не раставили корабли');
                    TextColor(Black);
                  end
                  else
                  begin
                    my_init_ships := false;
                    isExit_option := true;
                    init_ships_base(pc_ships);
                    init_ships_coords(pc_ships);
                    infor_of_point.pc.point.x := 0;
                    infor_of_point.pc.point.y := 0;
                    player_run_game;
                    if stop_game then Exit;
                  end;
                end;
              1: 
                begin
                  my_init_ships := true;
                  update_ships;
                  infor_of_point.player.count := 10;
                  infor_of_point.player.set_numder_of_ship := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
                  write_count_ships;
                end;
              2: 
                begin
                  allocation_ships;
                  if infor_of_point.player.count = 10 then my_init_ships := true;
                end;
              3: 
                begin
                  isExit_option := true;
                  clear_cache(my_ships);
                end;
            end;
          end;
      end;
      showMenu_option;
    end;
  until isExit_option;
end;

procedure clear_cache(var ships: t_ships);
var
  i, j: byte;
begin
  ships.area_coord := [];
  ships.beaten_coord.kill := [];
  ships.beaten_coord.missed := [];
  infor_of_point.player.count := 0;
  infor_of_point.player.set_numder_of_ship := [];
  new_record.score := 0;
  new_record.name := '';
  ships.kill_ships.one := 4;
  ships.kill_ships.two := 3;
  ships.kill_ships.three := 2;
  ships.kill_ships.four := 1;
  for i := 0 to 9 do
  begin
    ships.ships[i + 1].beaten := 0;
    for j := 0 to 9 do
      ships.pitch[i, j] := 0;
  end;
end;

function point_in_pitch(point: t_point): boolean;
var
  x, y: boolean;
begin
  if point.x in [0..9] then x := true
  else x := false;
  if point.y in [0..9] then y := true
  else y := false;
  Result := x and y; 
end;

procedure regiter_ship(i: byte; var ships: t_ships; var set_: t_set_line_coord; allocation: boolean);
var
  k, j: byte;
  buf, point: t_point;
  dir: Tdir;
begin
  set_ := [];
  point.x := ships.ships[i].coord.x - 1;
  point.y := ships.ships[i].coord.y - 1;
  dir := ships.ships[i].dir;
  case dir of
    x_down: 
      begin
        point.x := ships.ships[i].coord.x - (ships.ships[i].Length - 1) - 1;
        dir := x_up
      end;
    y_up: 
      begin
        point.y := ships.ships[i].coord.y - (ships.ships[i].Length - 1) - 1;
        dir := y_down;
      end;
  end;
  buf.x := point.x;
  buf.y := point.y;
  case dir of
    x_up: 
      begin
        for k := 0 to 2 do
        begin
          point.y := buf.y;
          point.y := point.y + k;
          for j := 0 to ships.ships[i].Length + 1 do
          begin
            point.x := buf.x;
            point.x := point.x + j;
            if point_in_pitch(point) then 
            begin
              Include(ships.area_coord, translate_coords(point));
              Include(set_, translate_coords(point));
              if allocation then
              begin
                GotoXY(translate_coords_on_real_pitch(1, x_up, point.x), translate_coords_on_real_pitch(1, y_down, point.y));
                TextBackground(Red);
                Write(' ');
                TextBackground(2);
              end;
            end;
          end;
        end;
        point.x := buf.x + 1;
        point.y := buf.y + 1;
        for j := 0 to ships.ships[i].Length - 1 do
        begin
          ships.pitch[point.x + j, point.y] := i;
        end;
      end;
    y_down:
      begin
        for k := 0 to 2 do
        begin
          point.x := buf.x;
          point.x := point.x + k;
          for j := 0 to ships.ships[i].Length + 1 do
          begin
            point.y := buf.y;
            point.y := point.y + j;
            if point_in_pitch(point) then 
            begin
              Include(ships.area_coord, translate_coords(point));
              Include(set_, translate_coords(point));
              if allocation then
              begin
                GotoXY(translate_coords_on_real_pitch(1, x_up, point.x), translate_coords_on_real_pitch(1, y_down, point.y));
                TextBackground(Red);
                Write(' ');
                TextBackground(2);
              end;
            end;
          end;
        end;
        point.x := buf.x + 1;
        point.y := buf.y + 1;
        for j := 0 to ships.ships[i].Length - 1 do
        begin
          ships.pitch[point.x, point.y + j] := i;
        end;
      end;
  end;
end;

function translate_coords(point: t_point): t_line_coord ;
begin
  Result := point.y * 10 + point.x;
end;

function is_ship_crossed(ships: t_ships; i: byte): boolean;
var
  line_coords_begin: byte;
  line_coords_end: byte;
begin
  line_coords_begin := translate_coords(ships.ships[i].coord);
  case ships.ships[i].dir of
    y_up: ships.ships[i].coord.y := ships.ships[i].coord.y - ships.ships[i].Length + 1;
    y_down: ships.ships[i].coord.y := ships.ships[i].coord.y + ships.ships[i].Length - 1;
    x_up: ships.ships[i].coord.x := ships.ships[i].coord.x + ships.ships[i].Length - 1;
    x_down: ships.ships[i].coord.x := ships.ships[i].coord.x - ships.ships[i].Length + 1
  end;
  line_coords_end := translate_coords(ships.ships[i].coord);
  result := not ((line_coords_begin in ships.area_coord) or (line_coords_end in ships.area_coord));
end;

function is_on_fild(ships: t_ships; i: byte): boolean;
begin
  case ships.ships[i].dir of 
    x_down: result := (ships.ships[i].coord.x - ships.ships[i].Length + 1 < 10) and (ships.ships[i].coord.x - ships.ships[i].Length + 1 >= 0);
    y_up: result := (ships.ships[i].coord.y - ships.ships[i].Length + 1 < 10) and (ships.ships[i].coord.y - ships.ships[i].Length + 1 >= 0);
    y_down: result := (ships.ships[i].coord.y + ships.ships[i].Length - 1 < 10) and (ships.ships[i].coord.y + ships.ships[i].Length - 1 >= 0);
    x_up: result := (ships.ships[i].coord.x + ships.ships[i].Length - 1 < 10) and (ships.ships[i].coord.x + ships.ships[i].Length - 1 >= 0);
  end;
end;

function is_right_coords(ships: t_ships; i: byte): boolean;
begin
  Result := is_on_fild(ships, i) and is_ship_crossed(ships, i);
end;

function random_point: t_point ;
var
  point: t_point;
begin
  point.x := Random(10);
  point.y := Random(10);
  Result := point;
end;

function random_dir: Tdir;
var
  x: byte;
begin
  x := Random(2);
  if x = 0 then result := x_up
  else result := y_down;
end;

procedure init_ships_base(var ships_: t_ships);
var
  i: byte;
begin
  for i := 1 to 10 do
  begin
    ships_.ships[i].beaten := 0;
    case i of
      1: ships_.ships[i].Length := 4;
      2..3: ships_.ships[i].Length := 3;
      4..6: ships_.ships[i].Length := 2;
      7..10: ships_.ships[i].Length := 1;
    end;
  end;
  ships_.kill_ships.one := 4;
  ships_.kill_ships.two := 3;
  ships_.kill_ships.three := 2;
  ships_.kill_ships.four := 1;
end;

procedure init_ships_coords(var ships: t_ships);
var
  i: byte;
  set_: t_set_line_coord;
begin
  for i := 1 to 10 do
  begin
    repeat
      ships.ships[i].coord := Random_point;
      ships.ships[i].dir := Random_dir;
    until is_right_coords(ships, i);
    regiter_ship(i, ships, set_, false);
  end;
end;

procedure show_ships(color: byte);
var
  i, j, x, y: byte;
begin
  TextColor(color);
  for i := 0 to 9 do
  begin
    for j := 0 to 9 do
    begin
      GotoXY(translate_coords_on_real_pitch(1, x_up, i), translate_coords_on_real_pitch(1, y_down, j));
      if my_ships.pitch[i, j] <> 0 then  write('█');
    end;
  end;
  TextColor(0);
end;

procedure Background;
begin
  TextBackground(Green);
  ClrScr();
end;

procedure write_symbol(c: char);
begin
  Inc(i_symbol);
  new_record.name := new_record.name + c;
  GotoXY(28 + i_symbol, 20);
  write(c);
end;

procedure clear_symbol(c: char);
begin
  delete(new_record.name, length(new_record.name), 1);
  GotoXY(28 + i_symbol, 20);
  writeln(' ');
  GotoXY(28 + i_symbol, 20);
  Dec(i_symbol);
end;

function getKey(kSymbol: boolean): Tkey;
var
  c: char;
begin
  Result := kNote;
  if keyPressed then
  begin
    c := readkey;
    case c of
      #27: Result := kEsc;
      #13: Result := kEnter;
      #97..#122, #65..#90, #1040..#1103: if (i_symbol <> 20) and kSymbol then write_symbol(c);
      #8:
        begin
          if kSymbol then if (i_symbol <> 0) then clear_symbol(c);
        end;
      #0: 
        begin
          c := readKey;
          case c of 
            #37: Result := kLeft;
            #38: Result := kUp;
            #39: Result := kRight;
            #40: Result := kdoun;
          end;
        end;
    end;
    while KeyPressed do
    begin
      c := ReadKey;
      if c = #0 then ReadKey;
    end;
  end;
end;

procedure show_game_pitch_1;
var
  c, j, i: byte;
begin
  j := 2;
  GotoXY(1, j);
  Writeln('   a б в г д е ж з и к ');
  Inc(j);
  GotoXY(1, j);
  Writeln('  ┌─┬─┬─┬─┬─┬─┬─┬─┬─┬─┐');
  for i := 1 to 9 do
  begin
    Writeln(' ', i, '│ │ │ │ │ │ │ │ │ │ │');
    Writeln('  ├─┼─┼─┼─┼─┼─┼─┼─┼─┼─┤');
  end;
  Writeln('10│ │ │ │ │ │ │ │ │ │ │');
  Write('  └─┴─┴─┴─┴─┴─┴─┴─┴─┴─┘');
end;

procedure show_game_pitch_2;
var
  j, i: byte;
begin
  j := 2;
  GotoXY(58, j);
  Writeln(' a б в г д е ж з и к ');
  Inc(j);
  GotoXY(58, j);
  Writeln('┌─┬─┬─┬─┬─┬─┬─┬─┬─┬─┐');
  for i := 1 to 9 do
  begin
    Inc(j);
    GotoXY(57, j);
    Writeln(i, '│ │ │ │ │ │ │ │ │ │ │');
    Inc(j);
    GotoXY(58, j);
    Writeln('├─┼─┼─┼─┼─┼─┼─┼─┼─┼─┤');
  end;
  Inc(j);
  GotoXY(56, j);
  Writeln('10│ │ │ │ │ │ │ │ │ │ │');
  Inc(j);
  GotoXY(58, j);
  Write('└─┴─┴─┴─┴─┴─┴─┴─┴─┴─┘');
end;

procedure initMenu;
var
  i: byte;
begin
  textcolor(Black);
  for i := 0 to 3 do
    mainMenu.Items[i, 0] := ramka_up;
  for i := 0 to 3 do
    mainMenu.Items[i, 2] := ramka_down;
  mainMenu.Items[0, 1] := '║            игра          ║';
  mainMenu.Items[1, 1] := '║          рекорды         ║';
  mainMenu.Items[2, 1] := '║       правила игры       ║';
  mainMenu.Items[3, 1] := '║           выход          ║';
  
  mainMenu.activeItem := 0;
end;

procedure nextItem;
begin
  if   mainMenu.activeItem = 3 then
    mainMenu.activeItem := 0
  else inc(  mainMenu.activeItem);
end;

procedure prevItem;
begin
  if   mainMenu.activeItem = 0 then
    mainMenu.activeItem := 3
  else dec(  mainMenu.activeItem);
end;

procedure showMenu;
var
  posMenu, i, j: byte;
begin
  Background;
  posMenu := 3;
  for i := 0 to 3 do
  begin
    if i = mainMenu.activeitem then
      textBackground(13)
    else  textBackground(Yellow);
    for j := 0 to 2 do
    begin
      gotoXY(26, posMenu);
      Write(mainMenu.items[i, j]);
      Inc(PosMenu); 
    end;
    PosMenu := PosMenu + 3;
  end;
  textBackground(0);
end;

procedure runMenu;
var
  key: TKey;
begin
  isExit := false;
  repeat
    key := getkey(false);
    if key in [kUp, kDoun, kEnter] then
    begin
      case key of
        kUp: prevItem;
        kDoun: nextItem;
        kEnter:
          begin
            case mainMenu.activeItem of
              0: option_game;
              1: show_records;
              2: about_it; 
              3: exit_;
            end; 
          end;
      end;
      showMenu;
    end;
  until isExit;
end;

procedure page_1;
begin
  Background;
  show_game_pitch_1;
  GotoXY(25, 1);
  Writeln('В игру играют двое, вы и копьютер. В одном из своих');
  GotoXY(25, 2);
  Writeln('полей вы размещаете в тайне свои корабли:');
  GotoXY(25, 4);
  write('█');
  GotoXY(25, 6);
  write('█ ,█ █ █ █ - один четырёхпалубный корабль  ');
  GotoXY(25, 8);
  write('█');
  GotoXY(25, 10);
  write('█');
  GotoXY(25, 11);
  write('        █');
  GotoXY(25, 13);
  write('█ █ █ , █ - два трёхпалубныx корабля');
  GotoXY(25, 15);
  write('        █');
  GotoXY(25, 17);
  write('█');
  GotoXY(25, 19);
  write('█ , █ █ - три двухпалубный корабля');
  GotoXY(25, 22);
  write('█ - четыре однопалубных корабля');
  GotoXY(4, 4);
  write('█');
  GotoXY(4, 6);
  write('█');
  GotoXY(4, 8);
  write('█');
  GotoXY(4, 10);
  write('█');
  GotoXY(8, 6);
  write('█');
  GotoXY(8, 8);
  write('█');
  GotoXY(8, 10);
  write('█');
  GotoXY(4, 14);
  write('█');
  GotoXY(6, 14);
  write('█');
  GotoXY(8, 14);
  write('█');
  GotoXY(12, 4);
  write('█');
  GotoXY(12, 6);
  write('█');
  GotoXY(16, 4);
  write('█');
  GotoXY(18, 4);
  write('█');
  GotoXY(22, 4);
  write('█');
  GotoXY(22, 6);
  write('█');
  GotoXY(22, 16);
  write('█');
  GotoXY(16, 16);
  write('█');
  GotoXY(16, 8);
  write('█');
  GotoXY(10, 20);
  write('█');
  GotoXY(2, 24);
  TextColor(7);
  write('используй стрелки чтобы переходить по страницам или нажмите esc чтобы выйти.');
  TextColor(0);
  GotoXY(30, 25);
  Write('←  ', '1', ' стр  →');
end;

procedure next_iteams_about_it(var i: byte);
begin
  if i = 3 then i := 1
  else Inc(i);
end;

procedure prev_iteam_about_it(var i: byte);
begin
  if i = 1 then i := 3
  else Dec(i);
end;

procedure page_2;
var
  i: byte;
begin
  Background;
  show_game_pitch_1;
  show_game_pitch_2;
  GotoXY(25, 3);
  Write('Корабли недолжны соприкасатьса');
  GotoXY(24, 6);
  Write('←- Ни по стороне');
  GotoXY(44, 6);
  Write('Ни по углу -→');
  GotoXY(22, 4);
  write('█');
  GotoXY(22, 6);
  write('█');
  GotoXY(22, 8);
  write('█');
  GotoXY(22, 10);
  write('█');
  GotoXY(16, 10);
  write('█');
  GotoXY(18, 10);
  write('█');
  GotoXY(20, 10);
  write('█');
  for i := 1 to 4 do  
  begin
    GotoXY(22, 12 + i);
    write('│');
  end;
  GotoXY(16, 12);
  write('↑');
  GotoXY(16, 13);
  write('│');
  GotoXY(22, 12);
  write('↑');
  TextBackground(6);
  GotoXY(4, 14);
  write('трёхпалубный кор.');
  GotoXY(4, 18);
  write('четырёхпалубный кор.');
  GotoXY(61, 10);
  write('двухпалубный кор.');
  GotoXY(59, 14);
  write('трёхпалубный кор.');
  TextBackground(2);
  GotoXY(59, 4);
  write('█');
  GotoXY(61, 4);
  write('█');
  GotoXY(63, 4);
  write('█');
  GotoXY(65, 6);
  write('█');
  GotoXY(67, 6);
  write('█');
  for i := 1 to 7 do  
  begin
    GotoXY(59, 6 + i);
    write('│');
  end;
  GotoXY(67, 9);
  Write('│');
  GotoXY(59, 6);
  write('↑');
  GotoXY(67, 8);
  write('↑');
  GotoXY(24, 8);
  Writeln('После размещения своих кораблей');
  GotoXY(24, 10);
  Writeln('Вы пытаетесь угадать,');
  GotoXY(24, 12);
  Writeln('где находятся корабли противника.');
  GotoXY(24, 16);
  Write('Если вы ранили');
  GotoXY(24, 18);
  Write('   корабль, то');
  GotoXY(24, 20);
  Write('прямоугольнике');
  GotoXY(24, 22);
  Write('←- будет крестик.');
  for i := 1 to 10 do  
  begin
    GotoXY(40, 14 + i);
    write('│');
  end;
  GotoXY(42, 16);
  Write('Если убили то,');
  GotoXY(42, 18);
  Write('вокруг будут');
  GotoXY(42, 20);
  Write('отмечены');
  GotoXY(42, 22);
  Write('звездочки -→');
  TextBackground(12);
  GotoXY(22, 22);
  Write('X');
  GotoXY(59, 22);
  Write('X');
  TextBackground(2);
  GotoXY(59, 20);
  Write('*');
  GotoXY(61, 20);
  Write('*');
  GotoXY(61, 22);
  Write('*');
  GotoXY(2, 24);
  TextColor(7);
  write('используй стрелки чтобы переходить по страницам или нажмите esc чтобы выйти.');
  TextColor(0);
  GotoXY(30, 25);
  Write('←  ', '2', ' стр  →');
  TextColor(0);
end;


procedure page_3;
begin
  Background;
  show_game_pitch_1;
  GotoXY(4, 4);
  write('█');
  GotoXY(4, 6);
  write('█');
  GotoXY(4, 8);
  write('█');
  GotoXY(4, 10);
  write('█');
  GotoXY(8, 6);
  write('█');
  GotoXY(8, 8);
  write('█');
  GotoXY(8, 10);
  write('█');
  GotoXY(4, 14);
  write('█');
  GotoXY(6, 14);
  write('█');
  GotoXY(8, 14);
  write('█');
  GotoXY(12, 4);
  write('█');
  GotoXY(12, 6);
  write('█');
  GotoXY(16, 4);
  write('█');
  GotoXY(18, 4);
  write('█');
  GotoXY(22, 4);
  write('█');
  GotoXY(22, 6);
  write('█');
  GotoXY(22, 16);
  write('█');
  GotoXY(16, 16);
  write('█');
  GotoXY(16, 8);
  write('█');
  GotoXY(10, 20);
  write('█');
  GotoXY(20, 20);
  write('*');
  GotoXY(20, 10);
  write('*');
  GotoXY(10, 10);
  write('*');
  GotoXY(16, 20);
  write('*');
  GotoXY(18, 18);
  write('*');
  GotoXY(4, 20);
  write('*');
  GotoXY(10, 4);
  write('*');
  GotoXY(6, 4);
  write('*');
  TextColor(13);
  GotoXY(10, 4);
  write('*');
  TextColor(Black);
  GotoXY(25, 1);
  Writeln('');
  GotoXY(25, 3);
  Writeln('Когда копьтер промахивается его звезда');
  GotoXY(25, 5);
  Writeln('загорается фиолетовым цветом. На следующем ходу');
  GotoXY(25, 7);
  Writeln('старая звезда гаснет, а новая загораеться.');
  GotoXY(25, 9);
  Writeln('Если вы хотите выйти во время игрового процесса.');
  GotoXY(25, 11);
  Writeln('Надо нажать клавишу Esc');
  TextColor(7);
  GotoXY(2, 24);
  write('используй стрелки чтобы переходить по страницам или нажмите esc чтобы выйти.');
  TextColor(0);
  GotoXY(30, 25);
  Write('←  ', '3', ' стр  →');
  TextColor(0);
end;


procedure about_it;
var
  i: byte;
  key: TKey;
begin
  i := 1;
  page_1;
  repeat
    key := getkey(false);
    if key in [kRight, kLeft] then
    begin
      case key of
        kRight: next_iteams_about_it(i); 
        kLeft: prev_iteam_about_it(i);
      end;
      case i of
        1: page_1;
        2: page_2;
        3: page_3;
      end;
    end;
  until kEsc = key;
  Background;
end;

procedure exit_;
begin
  isExit := true;
end;

procedure show_records;
var
  t1: file of Trecords;
  y, j, i: byte;
  records: Trecords;
begin
  Background;
  writeln('╔═══╦════════════════════════════════════════════════════════╦══════════════╗');
  writeln('║ № ║  ИМЯ                                                   ║   ХОДЫ       ║');
  for i := 1 to 9 do 
  begin
    writeln('╠═══╬════════════════════════════════════════════════════════╬══════════════╣');
    write('║ ', i, '.');   
    writeln('║                                                        ║              ║');
  end;
  writeln('╠═══╬════════════════════════════════════════════════════════╬══════════════╣');
  writeln('║10.║                                                        ║              ║');
  writeln('╚═══╩════════════════════════════════════════════════════════╩══════════════╝');
  TextColor(7);
  writeln('                   Для выхода нажмите клавишу esc...');
  TextColor(Black);
  y := 4;
  assign(t1, 'game_records.iso');
  Reset(t1);
  
  for i := 1 to FileSize(t1) do
  begin
    GotoXY(6, y);
    Read(t1, records);
    Write(records.name);
    GotoXY(70, y);
    Write(records.score);
    y := y + 2;
  end;
  Close(t1);
  repeat
    if getKey(false) = kEsc then break;
  until false;
  
  Background; 
end;

begin
  assign(t, 'game_records.iso');
  Assign(t1, 'output.txt');
  try
    Reset(t);
  except
    Rewrite(t);
  end;
  Close(t);
  Rewrite(t1);
  Close(t1);
  Background;
  initMenu;
  showMenu;
  runMenu;
end.