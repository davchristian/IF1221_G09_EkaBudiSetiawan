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

cekNama(Nama, NamaSblmnya, Nama) :-
    \+ member(Nama, NamaSblmnya), !.

cekNama(_, NamaSblmnya, NamaValid) :-
    write('Nama sdh digunakan. Masukkan nama lain: '),
    read(NamaBaru),
    cekNama(NamaBaru, NamaSblmnya, NamaValid).