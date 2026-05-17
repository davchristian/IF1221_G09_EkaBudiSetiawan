% Deklarasi dinamis
:- dynamic(kartu_pemain/2).
:- dynamic(discard_top/1).

% 1. mainkanKartu_mechanics(NomorUrut)
mainkanKartu_mechanics(_) :-
    \+ gameMulai, !,
    write('Game belum dimulai! Gunakan startGame.').

mainkanKartu_mechanics(NomorUrut) :-
    giliran(Pemain),
    kartu_pemain(Pemain, Hand),

    % Validasi apakah NomorUrut ada di dalam range list kartu di tangan
    length(Hand, Len),
    (NomorUrut < 1 ; NomorUrut > Len), !,
    write('Nomor urut kartu tidak valid! Coba lihatKartu lagi.').

mainkanKartu_mechanics(NomorUrut) :-
    giliran(Pemain),
    kartu_pemain(Pemain, Hand),

    % Ambil kartu dari tangan berdasarkan NomorUrut
    nth1(NomorUrut, Hand, KartuPilihan),
    KartuPilihan = kartu(Tipe, Warna, Nilai),

    % Ambil info kartu teratas di meja
    discard_top(KartuTop),
    KartuTop = kartu(_, WarnaTop, NilaiTop),

    % Validasi: Warna sama, nilai/tipe sama, atau kartu wild (warna hitam)
    (Warna == WarnaTop ; Nilai == NilaiTop ; Warna == hitam), !,

    % Eksekusi: Hapus kartu dari tangan
    hapus_elemen(NomorUrut, Hand, NewHand),
    retract(kartu_pemain(Pemain, _)),
    asserta(kartu_pemain(Pemain, NewHand)),

    % Eksekusi: Update discard pile di meja
    retract(discard_top(_)),
    asserta(discard_top(KartuPilihan)),

    format('~w memainkan kartu: ~w-~w.~n', [Pemain, Warna, Nilai]),

    % Pindah giliran ke pemain selanjutnya (belum efek skip/reverse)
    nextTurn.

% Jika kondisi di atas gagal (kartu tidak cocok)
mainkanKartu_mechanics(_) :-
    write('Kartu tidak valid! Silakan masukkan pilihan kartu kembali.').

% 2. ambilKartu_mechanics
ambilKartu_mechanics :-
    \+ gameMulai, !,
    write('Game belum dimulai! Gunakan startGame.').

ambilKartu_mechanics :-
    giliran(Pemain),
    kartu_pemain(Pemain, Hand),

    % Ambil satu kartu acak (memanggil helper)
    get_random_card(KartuBaru),

    % Tambahkan ke tangan
    append(Hand, [KartuBaru], NewHand),
    retract(kartu_pemain(Pemain, _)),
    asserta(kartu_pemain(Pemain, NewHand)),

    format('~w mendapatkan kartu baru.~n', [Pemain]),

    % Pindah giliran
    nextTurn.

% HELPER FUNCTION (membagi 7 kartu di awal + set kartu pertama di discard pile)

% Helper: Pindah giliran
nextTurn :-
    giliran(PemainSekarang),
    daftarPemain(Urutan),

    % Cari siapa pemain selanjutnya di dalam list
    next_player(PemainSekarang, Urutan, PemainSelanjutnya),

    % Update giliran
    retract(giliran(_)),
    asserta(giliran(PemainSelanjutnya)),
    nl, format('Giliran ~w.~n', [PemainSelanjutnya]).

% Mencari pemain selanjutnya (circular list)
next_player(X, List, Next) :-
    append(_, [X, Next | _], List), !.
next_player(X, List, Next) :-
    last(List, X),
    List = [Next | _], !.

% Helper: Hapus elemen berdasarkan Index
hapus_elemen(1, [_|T], T) :- !.
hapus_elemen(N, [H|T], [H|R]) :-
    N1 is N - 1,
    hapus_elemen(N1, T, R).

% Helper (sementara untuk test code): Ambil kartu acak dari deck.pl
get_random_card(kartu(Tipe, Warna, Nilai)) :-
    findall(kartu(T, W, N), kartu(T, W, N), SemuaKartu),
    random_member(kartu(Tipe, Warna, Nilai), SemuaKartu).