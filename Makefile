##========= Copyright © 2023, Sillies Industries, All rights reserved. ============//
## $Author: Amélie Heinrich
## $Project: Silly
## $Create Time: 25/12/2023 23:34
##=============================================================================//

NAME = Game.exe

SRC = source

all: $(NAME)

init:
	mkdir build

$(NAME):
	odin build $(SRC) -out:build/$(NAME) -debug

clean:
	rm build/$(NAME)

re: clean all
