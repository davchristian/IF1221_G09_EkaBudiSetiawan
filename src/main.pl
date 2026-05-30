% Memuat semua modul permainan
:- include('deck.pl').
:- include('player.pl').
:- include('setup.pl').
:- include('check.pl').
:- include('mechanics.pl').
:- include('save.pl').
:- include('load.pl').

% Pesan sambutan saat file diload
:- initialization(tampilkan_banner).

tampilkan_banner :-
    nl,
    write('=============================================='), nl,
    write('         SELAMAT DATANG DI GAME UNI           '), nl,
    write('              Kelompok 09                     '), nl,
    write('=============================================='), nl,
    write('Ketik "startGame." untuk memulai permainan.'), nl, nl.
