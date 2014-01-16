dotfiles_dir=$(shell pwd)

links=$(HOME)/.bash_aliases $(HOME)/.bashrc $(HOME)/.tmux.conf $(HOME)/.dotfiles

all : $(links)
	. $(HOME)/.bashrc

$(HOME)/.bash_aliases : aliases
	ln -s $(dotfiles_dir)/aliases ~/.bash_aliases
	
$(HOME)/.bashrc : bashrc
	ln -s $(dotfiles_dir)/bashrc ~/.bashrc
	
$(HOME)/.tmux.conf : tmux.conf
	ln -s $(dotfiles_dir)/tmux.conf ~/.tmux.conf

$(HOME)/.dotfiles :
	ln -s $(dotfiles_dir) ~/.dotfiles

remake : clean all

clean : 
	rm $(links)
