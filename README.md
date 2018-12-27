# dino-jump
This is a Verilog implementation for the famous Chrome game. The top-level module is in main.v, which in turn uses the controller module to create VGA signals. The controller is a giant multiplexor which gives different characters and sprites certain clock cycles to erase (paint black) the old position and repaint in the new position.
