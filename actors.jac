import:py pygame;

g_vars = {};
g_vars['width'] = 416;
g_vars['height'] = 416;
g_vars['fps'] = 30;
g_vars['grid'] = 32;
g_vars['window'] = pygame.display.set_mode(
    [g_vars['width'], g_vars['height']], pygame.HWSURFACE);


object Rectangle{
    can init(x,y,w,h){
        <self>.x = x;
        <self>.y = y;
        <self>.w = w;
        <self>.h = h;
    }

    can intersects(other){
        left = <self>.x;
        top = <self>.y;
        right = <self>.x + <self>.w;
        bottom = <self>.y + <self>.h;

        oleft = other.x;
        otop = other.y;
        oright = other.x + other.w;
        obottom = other.y + other.h;

        #####
        report not (left >= oright or right <= oleft or top >= obottom or bottom <= otop);
}
}

object Frog:Rectangle{

    can init(x,y,w){
        <super>.init(x, y, w, w); ### doubt , how to super(Frog, self).__init__(x, y, w, w)
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

    can move(xdir, ydir){
        <self>.x += xdir * g_vars['grid'];
        <self>.y += ydir * g_vars['grid'];
    }

    can attach(obstacle){
        <self>.attached = obstacle;
    }

    can update(){
        if <self>.attached is not None { ### doubt here
            <self>.x += <self>.attached.speed;
        }
        if <self>.x + <self>.w > g_vars['width']{
            <self>.x = g_vars['width'] - <self>.w;
        }
        if <self>.x < 0 {
            <self>.x = 0;
        }
        if <self>.y + <self>.h > g_vars['width']{
            <self>.y = g_vars['width'] - <self>.w;
        }   
        if <self>.y < 0 {
            <self>.y = 0 ;
        }     
    }

    can draw(){
        rect = Rect([<self>.x, <self>.y], [<self>.w, <self>.h]);
        pygame.draw.rect(g_vars['window'], <self>.color, rect);
    }     
        
}

object Obstacle:Rectangle{
    can init(x,y,w,h,s,c){
        <super>.init(x, y, w, h);
        <self>.color = c;
        <self>.speed = s;
    }

    can update(){
        <self>.x += <self>.speed;
        if <self>.speed > 0 and <self>.x > g_vars['width'] + g_vars['grid']{
            <self>.x = -<self>.w;
        }
        elif <self>.speed < 0 and <self>.x < - <self>.w{
            <self>.x = g_vars['width'];
        }
    }
    can draw(){
        pygame.draw.rect(g_vars['window'], <self>.color,
                         Rect([<self>.x, <self>.y], [<self>.w, <self>.h]));
    }
}

object Lane:Rectangle{
    can init(y,t='safety', c=None, n=0, l=0, spc=0, spd=0){
        <super>.init(0, y * g_vars['grid'], g_vars['width'], g_vars['grid']);
        <self>.type = t;
        <self>.color = c;
        <self>.obstacles = [];

        offset = 0;

        if <self>.type == 'car'{
            o_color = (128, 128, 128);
        } 
        if <self>.type == 'log'{
            o_color = (185, 122, 87);
        }        
        for i in range(n){
            <self>.obstacles.append(Obstacle(
                offset + spc * i, y * g_vars['grid'], l * g_vars['grid'], g_vars['grid'], spd, o_color));
        }
    }

    can check(frog){
        checked = False;
        attached = False;
        frog.attach(None);

        for obstacle in <self>.obstacles{
            if frog.intersects(obstacles){
                if <self>.type == "car"{
                    frog.reset();
                    checked = True;
                }

                if <self>.type == "log"{
                    attached = True;
                    frog.attach(obstacle);
                }
            }
        }

        if not attached and <self>.type == "log"{
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
           pygame.draw.rect(g_vars['window'], <self>.color, Rect(
                [<self>.x, <self>.y], [<self>.w, <self>.h]));
        }

        for obstacle in <self>.obstacles{
            obstacle.draw();
        }
    }
}


object Score{

    can init(){
        <self>.score = 0;
        <self>.high_score = 0;
        <self>.high_lane = 1;
        <self>.lives = 3;
    }

    can update(points){
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