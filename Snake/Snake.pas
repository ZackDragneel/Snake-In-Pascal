Program Snake;

Uses SysUtils, Windows;

Const
    CSI = chr(27) + '['; {Control Sequence Introducer}

    LEVEL_X_POSITION = 1;
    LEVEL_Y_POSITION = 1;

    LEVEL_WIDTH = 51;
    LEVEL_HEIGHT = 33;

    GLOBAL_LEVEL_WIDTH = (LEVEL_X_POSITION + LEVEL_WIDTH) - 1; {Width and height relative to the origin of the console (1, 1)}
    GLOBAL_LEVEL_HEIGHT = (LEVEL_Y_POSITION + LEVEL_HEIGHT - 1);

Type
    directions = (north, south, east, west);

    position = record
        x, y : integer;
    end;

    player = record
        position : array[1..100] of position;
        direction : directions;
        size : integer;
        speed : integer;
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

begin
    for col := x to width do begin
        for line := y to height do begin
            drawAt(col, line);
            if ((col = x) or (col = width)) and ((line = y) or (line = height)) then begin {if it's a corner}
                if (col = x) then
                        if (line = y) then write('É') else write('È');
                if (col = width) then
                        if (line = y) then write('»') else write('¼');
            end else begin
                if (col = x) or (col = width) then write ('º')
                else if (line = y) or (line = height) then write ('Í'); {Draw sides}
            end;
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
    if (snake.position[1].x >= GLOBAL_LEVEL_WIDTH) or
       (snake.position[1].y >= GLOBAL_LEVEL_HEIGHT) or
       (snake.position[1].x <= LEVEL_X_POSITION) or
       (snake.position[1].y <= LEVEL_Y_POSITION) then collision := true;

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
    drawAt(GLOBAL_LEVEL_WIDTH + 3, LEVEL_Y_POSITION);
    write('Score = ', score);
end;

Procedure updateFruit (var fruit : position; var snake : player; var score : integer);
begin
    if (fruit.x = snake.position[1].x) and (fruit.y = snake.position[1].y) then begin
        addSegment(snake);
        randomize;
        fruit.x := random(GLOBAL_LEVEL_WIDTH - 1 - LEVEL_X_POSITION) + LEVEL_X_POSITION + 1;
        fruit.y := random(GLOBAL_LEVEL_HEIGHT - 1 - LEVEL_Y_POSITION) + LEVEL_Y_POSITION + 1;
        drawAt(fruit.x, fruit.y);
        write('þ');
        score := score + 10;
        snake.speed := snake.speed + 5;
    end;
end;

Var
    snake1 : player;
    startingPos : position;
    fruit : position;
    score : integer;
    i : integer;

Begin
    {Hide cursor and draw level}
    hideCursor;
    drawRect(LEVEL_X_POSITION, LEVEL_Y_POSITION, GLOBAL_LEVEL_WIDTH, GLOBAL_LEVEL_HEIGHT);

    {Set up snake starting position and direction}
    snake1.position[1].x := LEVEL_X_POSITION + (LEVEL_WIDTH div 2);
    snake1.position[1].y := LEVEL_Y_POSITION + (LEVEL_HEIGHT div 2);
    snake1.direction := north;
    snake1.size := 1;
    snake1.speed := 0;

    {Set Up score}
    score := 0;

    {Set Up starting fruit}
    randomize;
    fruit.x := random(GLOBAL_LEVEL_WIDTH - 1 - LEVEL_X_POSITION) + LEVEL_X_POSITION + 1;
    fruit.y := random(GLOBAL_LEVEL_HEIGHT - 1 - LEVEL_Y_POSITION) + LEVEL_Y_POSITION + 1;
    drawAt(fruit.x, fruit.y);
    write('þ');

    {Start of game loop}
    while true do begin
        while (not collision(snake1)) do begin
            input (snake1);

            drawAt(snake1.position[snake1.size].x, snake1.position[snake1.size].y);
            write(' ');

            updateSnake (snake1);
            updateFruit (fruit, snake1, score);

            drawScore(score);
            drawSnake(snake1);

            sleep(150 - snake1.speed);
        end;
    end;
End.
