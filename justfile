default:
    @just --list

switch:
    alejandra . && nh os switch .

update:
    alejandra . && nh os switch . --update

clean:
    nh clean all --keep 3 --keep-since 7d
