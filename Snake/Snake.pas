Program Snake;

Uses SysUtils, Windows;

Const
    CSI = chr(27) + '['; {Control Sequence Introducer}
    LEVEL_WIDTH = 51;
    LEVEL_HEIGHT = 33;

Type
    directions = (north, south, east, west);

    position = record
        x, y : integer;
    end;

    player = record
        position : array[1..20] of position;
        direction : directions;
        size : integer;
    end;

Procedure clearScreen;
begin
    write(CSI, 3, 'J'); {Erase scrolling}
    write(CSI, 2, 'J');
    write(CSI, 'H'); {Return cursor to home position}
end;

Procedure hideCursor;
begin
    write(CSI, '?', 25, 'l'); {Make cursor invisible}
end;

Procedure drawAt (x, y: integer);
begin
    write(CSI, y, ';', x, 'H'); {Move cursor to line and column}
end;

Procedure drawRect(x, y, width, height: integer);
var
    col, line: integer;
    absoluteWidth, absoluteHeight: integer;

begin
    absoluteWidth := (x + width) - 1;
    absoluteHeight := (y + height) - 1;
    for col := x to absoluteWidth do begin
        for line := y to absoluteHeight do begin
            drawAt(col, line);
            if (col = x) or (col = absoluteWidth) or (line = y) or (line = absoluteHeight) then write('x');
        end;
    end;
end;

Procedure updateSnake (var snake : player);
var
    i: integer;
begin
    for i := snake.size downto 2 do begin
        snake.position[i].x := snake.position[i-1].x;
        snake.position[i].y := snake.position[i-1].y;
    end;

    case snake.direction of
        north: snake.position[1].y := snake.position[1].y - 1;
        south: snake.position[1].y := snake.position[1].y + 1;
        west: snake.position[1].x := snake.position[1].x + 1;
        east: snake.position[1].x := snake.position[1].x - 1;
    end;
end;

Procedure drawSnake (snake : player);
var
    i: integer;
begin
    drawAt(snake.position[1].x, snake.position[1].y);
    write(0);

    for i := snake.size downto 2 do begin
        drawAt(snake.position[i].x, snake.position[i].y);
        write('o');
    end;
end;

Procedure addSegment(var snake : player);
begin
    snake.size := snake.size + 1;

    snake.position[snake.size] := snake.position[snake.size-1];
end;

Function collision (snake : player): boolean;
var
    i : integer;
begin
    collision := false;
    if (snake.position[1].x >= LEVEL_WIDTH) or (snake.position[1].y >= LEVEL_HEIGHT) or (snake.position[1].x <= 1) or (snake.position[1].y <= 1) then collision := true;

    if (snake.size > 2) then begin
        for i := 2 to snake.size do begin
            if (snake.position[1].x = snake.position[i].x) and (snake.position[1].y = snake.position[i].y) then collision := true;
        end;
    end;
end;

Procedure input (var snake : player);
begin
    if (GetAsyncKeyState(ord('W')) < 0) and (snake.direction <> north) and (snake.direction <> south) then snake.direction := north;
    if (GetAsyncKeyState(ord('A')) < 0) and (snake.direction <> east) and (snake.direction <> west) then snake.direction := east;
    if (GetAsyncKeyState(ord('S')) < 0) and (snake.direction <> south) and (snake.direction <> north) then snake.direction := south;
    if (GetAsyncKeyState(ord('D')) < 0) and (snake.direction <> west) and (snake.direction <> east) then snake.direction := west;
end;

Procedure drawScore (score : integer);
begin
    drawAt(LEVEL_WIDTH + 3, 1);
    write('Score = ', score);
end;

Var
    snake1 : player;
    startingPos : position;
    fruit : array [1..20] of position;
    score : integer;
    i : integer;

Begin
    {Hide cursor and draw level}
    hideCursor;
    drawRect(1, 1, LEVEL_WIDTH, LEVEL_HEIGHT);

    {Set up snake starting position and direction}
    snake1.position[1].x := 1 + (LEVEL_WIDTH div 2);
    snake1.position[1].y := 1 + (LEVEL_HEIGHT div 2);
    snake1.direction := north;
    snake1.size := 1;

    {Set Up score}
    score := 0;

    {Set Up starting fruit}
    randomize;
    for i := 1 to 20 do begin
        fruit[i].x := random(LEVEL_WIDTH);
        fruit[i].y := random(LEVEL_HEIGHT);
        drawAt(fruit[i].x, fruit[i].y);
        write('x');
    end;

    {Start of game loop}
    while true do begin
        while (not collision(snake1)) do begin
            input (snake1);

            drawAt(snake1.position[snake1.size].x, snake1.position[snake1.size].y);
            write(' ');

            updateSnake (snake1);

            for i := 1 to 20 do begin
                if (fruit[i].x = snake1.position[1].x) and (fruit[i].y = snake1.position[1].y) then begin
                    drawAt(fruit[i].x, fruit[i].y);
                    addSegment(snake1);
                    fruit[i].x := 0;
                    fruit[i].y := 0;
                    score := score + 10;
                end;
            end;

            drawScore(score);
            drawSnake(snake1);

            sleep(80);
        end;
    end;
End.
