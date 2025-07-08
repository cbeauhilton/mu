default:
    @just --list

switch:
    nh os switch .

update:
    nh os switch . --update

clean:
    nh clean all --keep 3 --keep-since 7d
