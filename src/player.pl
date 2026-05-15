mintaJmlhPemain(Jmlh) :-
    write('Masukkan jumlah pemain: '),
    read(Input),

    (
        integer(Input),
        Input >= 2,
        Input =< 4
    ->
        Jmlh = Input
    ;
        write('Mohon masukkan angka antara 2 - 4.'), nl,
        mintaJmlhPemain(Jmlh)
    ).

ambilSemuaNama(0, _, []).

ambilSemuaNama(N, NamaSblmnya, [Nama | Sisa]) :-
    N > 0,

    length(NamaSblmnya, Len),
    Index is Len + 1,

    write('Masukkan nama pemain '),
    write(Index),
    write(': '),
    read(InputNama),

    cekNama(InputNama, NamaSblmnya, Nama),

    N1 is N - 1,
    ambilSemuaNama(N1, [Nama | NamaSblmnya], Sisa).

huruf_awal_besar(Nama) :-
    atom(Nama),
    atom_codes(Nama, [C|_]),
    C >= 65,
    C =< 90.

cekNama(Nama, NamaSblmnya, Nama) :-
    atom(Nama),
    huruf_awal_besar(Nama),
    \+ member(Nama, NamaSblmnya), !.

cekNama(Nama, NamaSblmnya, NamaValid) :-
    ( \+ atom(Nama) ->
        write('Nama harus diapit petik, contoh: ''RipanGanteng''. Masukkan nama lain: ')
    ; \+ huruf_awal_besar(Nama) ->
        write('Nama harus diawali huruf besar, contoh: ''RipanGanteng''. Masukkan nama lain: ')
    ; write('Nama sdh digunakan. Masukkan nama lain (diapit petik): ')
    ),
    read(NamaBaru),
    cekNama(NamaBaru, NamaSblmnya, NamaValid).