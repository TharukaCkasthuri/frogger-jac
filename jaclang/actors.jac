"""
Actors file
"""
import:py pygame;

global g_vars = {"width": 416, "height": 416, "fps": 30 , "grid": 32, "window" : pygame.display.set_mode([416, 416], pygame.HWSURFACE)};

object Rectangle{
    can <init>(x:int,y:int,w:int,h:int){
        <self>.x = x;
        <self>.y = y;
        <self>.w = w;
        <self>.h = h;
    }

    can intersects(other: actors.Obstacle){
        left1 = <self>.x;
        top1 = <self>.y;
        right1 = <self>.x + <self>.w;
        bottom1 = <self>.y + <self>.h;

        left2 = other.x;
        top2 = other.y;
        right2 = other.x + other.w;
        bottom2 = other.y + other.h;

        report not (left1 >= right2 or right1 <= left2 or top1 >= bottom2 or bottom1 <= top2);
}
}

object Frog:Rectangle{

    can <init>(x:int,y:int,w:int){
        <super>.<init>(x, y, w, w); 
        <self>.x0 = x;
        <self>.y0 = y;
        <self>.color = (34, 177, 76);
        <self>.attached = None;
    }

    can reset(){
        <self>.x = <self>.x0;
        <self>.y = <self>.y0;
        <self>.attach(None);
    }

    can move(xdir:int, ydir:int){
        <self>.x += xdir * g_vars['grid'];
        <self>.y += ydir * g_vars['grid'];
    }

    can attach(obstacle:actors.Obstacle){
        <self>.attached = obstacle;
    }

    can update(){
        if(<self>.attached is not None) { ### doubt here
            <self>.x += <self>.attached.speed;
        }
        if (<self>.x + <self>.w > g_vars['width']){
            <self>.x = g_vars['width'] - <self>.w;
        }
        if (<self>.x < 0) {
            <self>.x = 0;
        }
        if (<self>.y + <self>.h > g_vars['width']){
            <self>.y = g_vars['width'] - <self>.w;
        }   
        if (<self>.y < 0) {
            <self>.y = 0 ;
        }     
    }

    can draw(){
        rect = pygame.Rect([<self>.x, <self>.y], [<self>.w, <self>.h]);
        pygame.draw.rect(g_vars['window'], <self>.color, rect);
    }     

        
}

object Obstacle:Rectangle{
    can <init>(x:int, y:int, w:int, h:int, s:int, c:int){
        <super>.<init>(x, y, w, h);
        <self>.color = c;
        <self>.speed = s;
    }

    can update(){
        <self>.x += <self>.speed;
        if (<self>.speed > 0) and (<self>.x > g_vars['width'] + g_vars['grid']){
            <self>.x = -<self>.w;
        }
        elif (<self>.speed < 0) and (<self>.x < - <self>.w){
            <self>.x = g_vars['width'];
        }
    }
    can draw(){
        pygame.draw.rect(g_vars['window'], <self>.color,
                         pygame.Rect([<self>.x, <self>.y], [<self>.w, <self>.h]));
    }
}

object Lane:Rectangle{
    can <init>(y:int, t:str='safety', c:tuple=None, n:int=0, l:int=0, spc:int=0, spd:int=0){
        <super>.<init>(0, y * g_vars['grid'], g_vars['width'], g_vars['grid']);
        <self>.<>type = t;
        <self>.color = c;
        <self>.obstacles = [];

        offset = 0;

        if <self>.<>type == 'car'{
            o_color = (128, 128, 128);
        } 
        if <self>.<>type == 'log'{
            o_color = (185, 122, 87);
        }        
        for i in range(n){
            <self>.obstacles.append(Obstacle(
                offset + spc * i, y * g_vars['grid'], l * g_vars['grid'], g_vars['grid'], spd, o_color));
        }
    }

    can check(frog:actors.Frog){
        checked = False;
        attached = False;
        frog.attach(None);

        for obstacle in <self>.obstacles{
            if frog.intersects(obstacle){
                if <self>.<>type == "car"{
                    frog.reset();
                    checked = True;
                }

                if <self>.<>type == "log"{
                    attached = True;
                    frog.attach(obstacle);
                }
            }
        }

        if not attached and <self>.<>type == "log"{
            frog.reset();
            checked = True;
        }

        report checked;
    }

    can update(){
        for obstacle in <self>.obstacles{
            obstacle.update();
        }
    }

    can draw(){
        if <self>.color is not None{
           pygame.draw.rect(g_vars['window'], <self>.color, pygame.Rect(
                [<self>.x, <self>.y], [<self>.w, <self>.h]));
        }

        for obstacle in <self>.obstacles{
            obstacle.draw();
        }
    }
}


object Score{

    can <init>(){
        <self>.score = 0;
        <self>.high_score = 0;
        <self>.high_lane = 1;
        <self>.lives = 3;
    }

    can update(points:int){
        <self>.score += points;
        if <self>.score > <self>.high_score{
            <self>.high_score = <self>.score;
        }
    }

    can reset(){
        <self>.score = 0;
        <self>.high_lane = 1;
        <self>.lives = 3;
    }
}