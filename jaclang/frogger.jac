"""Frogger game made with Python3 and Pygame"""

import:py pygame;

include:jac actors;

global g_vars = {"width": 416, "height": 416, "fps": 30 , "grid": 32, "window" : pygame.display.set_mode([416, 416], pygame.HWSURFACE)};

object App{
    can <init>(){
        pygame.<>init();
        pygame.display.set_caption("Frogger");

        <self>.running = None;
        <self>.state =  None;
        <self>.frog = None;
        <self>.score = None;
        <self>.lanes = None;

        <self>.clock = pygame.time.Clock();
        <self>.font = pygame.font.SysFont('Courier New', 16);
    }

    can initialize(){
        <self>.running = True;
        <self>.state = 'START';

        <self>.frog = Frog(g_vars['width']/2 - g_vars['grid']/2,
                         12 * g_vars['grid'], g_vars['grid']);

        <self>.frog.attach(None);
        <self>.score = Score();

        <self>.lanes = [];
        <self>.lanes.append(Lane(1, c=(50, 192, 122)));
        <self>.lanes.append(Lane(2, t='log', c=(153, 217, 234),
                          n=2, l=6, spc=350, spd=1.2));

        <self>.lanes.append(Lane(3, t='log', c=(153, 217, 234),
                          n=3, l=2, spc=180, spd=-1.6));

        <self>.lanes.append(Lane(4, t='log', c=(153, 217, 234),
                          n=4, l=2, spc=140, spd=1.6));

        <self>.lanes.append(Lane(5, t='log', c=(153, 217, 234),
                          n=2, l=3, spc=230, spd=-2));

        <self>.lanes.append(Lane(6, c=(50, 192, 122)));

        <self>.lanes.append(Lane(7, c=(50, 192, 122)));

        <self>.lanes.append(Lane(8, t='car', c=(195, 195, 195),
                          n=3, l=2, spc=180, spd=-2));

        <self>.lanes.append(Lane(9, t='car', c=(195, 195, 195),
                          n=2, l=4, spc=240, spd=-1));

        <self>.lanes.append(Lane(10, t='car', c=(
            195, 195, 195), n=4, l=2, spc=130, spd=2.5));

        <self>.lanes.append(Lane(11, t='car', c=(
            195, 195, 195), n=3, l=3, spc=200, spd=1));

        <self>.lanes.append(Lane(12, c=(50, 192, 122)));
    }

    can event(event:pygame.event.Event){
        if (event.<>type == pygame.QUIT){
            <self>.running = False;
            }

        if event.<>type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE{
            <self>.running = False;
            }
            
        if <self>.state == 'START'{
            if event.<>type == pygame.KEYDOWN and event.key == pygame.K_RETURN{
                <self>.state =  'PLAYING';
            }
        }

        if <self>.state == 'PLAYING'{

            if event.<>type == pygame.KEYDOWN and event.key == pygame.K_LEFT{
                <self>.frog.move(-1, 0);
            } 
            if event.<>type == pygame.KEYDOWN and event.key == pygame.K_RIGHT{
                <self>.frog.move(1, 0);
            }
            if event.<>type == pygame.KEYDOWN and event.key == pygame.K_UP{
                <self>.frog.move(0, -1);
            }
            if event.<>type == pygame.KEYDOWN and event.key == pygame.K_DOWN{
                <self>.frog.move(0, 1);
            }  
        }           
    }


    can update(){
        for lane in self.lanes{
            lane.update();
        }

        lane_index = <self>.frog.y//g_vars['grid'] - 1;
        if <self>.lanes[lane_index].check(<self>.frog){
            <self>.score.lives -= 1;
            <self>.score.score = 0;
        }

        <self>.frog.update();

        if (g_vars["height"] - <self>.frog.y//g_vars['grid'] > self.score.high_lane){ #g_vars['grid'] > self.score.high_lane:
            if (<self>.score.high_lane == 11){
                <self>.frog.reset();
                <self>.score.update(200);
            }
            else{
                <self>.score.update(10);
                <self>.score.high_lane = (g_vars["height"] - <self>.frog.y)//g_vars['grid'];
            } 
        }

        if (self.score.lives == 0){
            <self>.frog.reset();
            <self>.score.reset();
            <self>.state = "START";
        }     
    }

    can draw(){
        g_vars['window'].fill((0, 0, 0));
        if <self>.state == 'START'{
            <self>.draw_text(
                "Frogger!", g_vars['width']/2, g_vars['height']/2 - 15, 'center');
            <self>.draw_text("Press ENTER to start playing.",
                           g_vars['width']/2, g_vars['height']/2 + 15, 'center');
        }

        if <self>.state == 'PLAYING'{
            <self>.draw_text("Lives: {0}".format(<self>.score.lives), 5, 8, 'left');
            <self>.draw_text("Score: {0}".format(
                <self>.score.score), 120, 8, 'left');
            <self>.draw_text("High Score: {0}".format(
                <self>.score.high_score), 240, 8, 'left');

            for lane in self.lanes{
                lane.draw();
            }
            <self>.frog.draw();     
        }

        pygame.display.flip();
    }

    can draw_text(t:str, x:float, y:float, a:str){
        text = <self>.font.render(t, False, (255, 255, 255));
        if a == 'center'{
            x -= text.get_rect().width / 2;
        }
        elif a == 'right'{
            x += text.get_rect().width;
        }
        g_vars['window'].blit(text, [x, y]);
    }


    can cleanup(){
        pygame.quit();
        quit();
    }

    can execute(){
        if <self>.initialize() == False{
            <self>.running = False;
        }
        while <self>.running{
            for event in pygame.event.get(){
                <self>.event(event);
            }
            <self>.update();
            <self>.draw();
            <self>.clock.tick(g_vars['fps']);
        }   
        <self>.cleanup();
    }
}

# Run the game
with entry {
    gameApp = App();
    gameApp.execute();
}

