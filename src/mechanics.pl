:- dynamic(status_UNI/1).
:- dynamic(warna_aktif/1).
:- dynamic(menunggu_respons_draw_two/0).
:- dynamic(menunggu_respons_draw_four/2).

mainkanKartu(_) :-
    \+ gameMulai, !, write('Game belum dimulai! Gunakan startGame.'), nl.

mainkanKartu(_) :-
    menunggu_respons_draw_four(_, _), !,
    write('Anda terkena efek Wild Draw Four! Anda hanya bisa menggunakan perintah "tantang." atau "ambilKartu."'), nl.

mainkanKartu(_) :-
    menunggu_respons_draw_two, !,
    write('Anda terkena efek Draw Two! Anda harus menggunakan perintah "ambilKartu."'), nl.

mainkanKartu(Nomor) :-
    giliran(Pemain),
    playerCard(Pemain, Hand),
    ( ambilKartuN(Nomor, Hand, KartuPilihan) ->
        activeCard(KartuTop),
        
        (warna_aktif(WA) -> WarnaAktif = WA ; KartuTop = kartu(WarnaAktif, _)),
        ( proses_kartu(Pemain, Nomor, KartuPilihan, KartuTop, WarnaAktif, Hand) ->
            playerCard(Pemain, HandBaru),
            ( HandBaru == [] -> endGame ; true )
        ; write('Kartu tidak valid untuk dimainkan atau dilarang menumpuk kartu aksi yang sama!'), nl
        )
    ; write('Nomor kartu salah.'), nl
    ).

proses_kartu(Pemain, Nomor, kartu(hitam, wildFour), kartu(_, JenisTop), WarnaAktif, Hand) :-
    JenisTop \= wildFour, !,
    ( punya_kartu_cocok(Hand, WarnaAktif) -> Legalitas = ilegal ; Legalitas = legal ),
    buang_dan_update(Pemain, Nomor, kartu(hitam, wildFour)),
    minta_warna_baru(WarnaBaru),
    retractall(warna_aktif(_)), asserta(warna_aktif(WarnaBaru)),
    asserta(menunggu_respons_draw_four(Pemain, Legalitas)),
    format('~w memainkan Wild Draw Four! Warna menjadi ~w.~n', [Pemain, WarnaBaru]),
    pindahGiliran(Pemain).

proses_kartu(Pemain, Nomor, kartu(hitam, wild), kartu(_, JenisTop), _, _) :-
    JenisTop \= wild, !,
    buang_dan_update(Pemain, Nomor, kartu(hitam, wild)),
    minta_warna_baru(WarnaBaru),
    retractall(warna_aktif(_)), asserta(warna_aktif(WarnaBaru)),
    format('~w memainkan Wild! Warna menjadi ~w.~n', [Pemain, WarnaBaru]),
    pindahGiliran(Pemain).

proses_kartu(Pemain, Nomor, kartu(Warna, drawTwo), kartu(_, JenisTop), WarnaAktif, _) :-
    JenisTop \= drawTwo,
    Warna == WarnaAktif, !,
    buang_dan_update(Pemain, Nomor, kartu(Warna, drawTwo)),
    retractall(warna_aktif(_)), asserta(warna_aktif(Warna)),
    asserta(menunggu_respons_draw_two),
    format('~w memainkan Draw Two! Pemain selanjutnya akan terkena denda.~n', [Pemain]),
    pindahGiliran(Pemain).

proses_kartu(Pemain, Nomor, kartu(Warna, Jenis), kartu(_, JenisTop), WarnaAktif, _) :-
    Jenis \= wild, Jenis \= wildFour, Jenis \= drawTwo,
    (Warna == WarnaAktif ; Jenis == JenisTop), !,
    buang_dan_update(Pemain, Nomor, kartu(Warna, Jenis)),
    retractall(warna_aktif(_)), asserta(warna_aktif(Warna)),
    format('~w memainkan kartu: ~w-~w.~n', [Pemain, Warna, Jenis]),
    ( Jenis == skip ->
        pindahGiliranSkip(Pemain)
    ; Jenis == reverse ->
        toggleArahPermainan,
        write('Arah permainan dibalik.'), nl,
        pindahGiliran(Pemain)
    ;
        pindahGiliran(Pemain)
    ). 

tantang :-
    \+ gameMulai, !, write('Game belum dimulai!'), nl.

tantang :-
    giliran(Penantang),
    menunggu_respons_draw_four(Pelempar, Legalitas), !,
    write('Tantangan dilakukan!'), nl,
    format('Memeriksa kartu ~w...~n', [Pelempar]),
    ( Legalitas == ilegal ->
        write('Tantangan BERHASIL!'), nl,
        format('~w terbukti memiliki kartu yang cocok dan mendapatkan 4 kartu penalti.~n', [Pelempar]),
        tarik_kartu_penalti(4, Pelempar)
    ;
        write('Tantangan GAGAL.'), nl,
        format('~w mendapatkan 6 kartu acak sebagai hukuman!~n', [Penantang]),
        tarik_kartu_penalti(6, Penantang)
    ),
    retractall(menunggu_respons_draw_four(_,_)),
    pindahGiliran(Penantang).

tantang :-
    write('Tidak ada penggunaan Wild Draw Four yang bisa ditantang saat ini.'), nl.

ambilKartu :-
    \+ gameMulai, !, write('Game belum dimulai!'), nl.

ambilKartu :-
    giliran(Pemain),
    ( menunggu_respons_draw_two ->
        write('Mengambil 2 kartu karena efek Draw Two...'), nl,
        tarik_kartu_penalti(2, Pemain),
        retractall(menunggu_respons_draw_two)
    ; menunggu_respons_draw_four(_, _) ->
        write('Anda memilih tidak menantang.'), nl,
        write('Mengambil 4 kartu karena efek Wild Draw Four...'), nl,
        tarik_kartu_penalti(4, Pemain),
        retractall(menunggu_respons_draw_four(_,_))
    ;
        tarik_kartu_penalti(1, Pemain),
        format('~w mendapatkan 1 kartu baru.~n', [Pemain])
    ),
    pindahGiliran(Pemain).

% Helper Functions
buang_dan_update(Pemain, Nomor, KartuPilihan) :-
    playerCard(Pemain, Hand),
    deleteKartu(Nomor, Hand, NewHand),
    retract(playerCard(Pemain, _)), assertz(playerCard(Pemain, NewHand)),
    retract(activeCard(_)), assertz(activeCard(KartuPilihan)),
    tambahKeDiscardPile(KartuPilihan).

minta_warna_baru(WarnaBaru) :-
    write('Pilih warna (merah/kuning/hijau/biru): '),
    read(Input),
    ( member(Input, [merah, kuning, hijau, biru]) -> WarnaBaru = Input
    ; write('Warna tidak valid! Coba lagi.'), nl, minta_warna_baru(WarnaBaru) ).

punya_kartu_cocok(Hand, WarnaAktif) :- member(kartu(WarnaAktif, _), Hand), !.
punya_kartu_cocok(Hand, _) :- activeCard(kartu(_, JenisTop)), member(kartu(_, JenisTop), Hand), !.

tarik_kartu_penalti(0, _) :- !.
tarik_kartu_penalti(N, Pemain) :-
    N > 0,
    deck(DeckSekarang),
    playerCard(Pemain, TanganSekarang),
    ( ambilNKartu(1, DeckSekarang, [KartuBaru], DeckBaru) ->
        append(TanganSekarang, [KartuBaru], TanganBaru),
        retract(playerCard(Pemain, _)), assertz(playerCard(Pemain, TanganBaru)),
        retract(deck(_)), assertz(deck(DeckBaru)),
        N1 is N - 1,
        tarik_kartu_penalti(N1, Pemain)
    ;
        write('[Sistem] Deck habis! Mengisi deck dari discard pile.'),
        shuffleDiscardPileToDeck,
        tarik_kartu_penalti(N, Pemain),
        nl
    ).

nextPlayer(PemainSaat, PemainBerikutnya) :-
    daftarPemain(Urutan),
    arahPermainan(Arah),
    ( Arah == clockwise ->
        ( append(_, [PemainSaat, PemainBerikutnya | _], Urutan) -> true
        ; last(Urutan, PemainSaat), Urutan = [PemainBerikutnya | _]
        )
    ;
        ( append(_, [PemainBerikutnya, PemainSaat | _], Urutan) -> true
        ; Urutan = [PemainSaat | _], last(Urutan, PemainBerikutnya)
        )
    ).
    
pindahGiliran(Pemain) :-
    nextPlayer(Pemain, PemainBerikutnya), 
    retract(giliran(Pemain)),
    assertz(giliran(PemainBerikutnya)),
    format('Giliran ~w.~n', [PemainBerikutnya]).

toggleArahPermainan :-
    ( arahPermainan(clockwise) ->
        retract(arahPermainan(clockwise)),
        assertz(arahPermainan(counterclockwise))
    ;
        retract(arahPermainan(counterclockwise)),
        assertz(arahPermainan(clockwise))
    ).

pindahGiliranSkip(Pemain) :-
    nextPlayer(Pemain, P1),
    nextPlayer(P1, P2),
    retract(giliran(Pemain)),
    assertz(giliran(P2)),
    write('Pemain berikutnya kehilangan giliran.'), nl,
    format('Giliran ~w.~n', [P2]).

uni(NomorUrut) :-
    giliran(Pemain),
    playerCard(Pemain, Tangan),
    length(Tangan, L),
    
    ( L =:= 2 ->
        ambilKartuN(NomorUrut, Tangan, KartuPilihan),
        activeCard(KartuAktif),
        KartuPilihan = kartu(WarnaPilihan, JenisPilihan),
        KartuAktif = kartu(WarnaAktif, JenisAktif),
        
        ( (WarnaPilihan == WarnaAktif ; JenisPilihan == JenisAktif ; WarnaPilihan == hitam) ->
            format('~w memainkan kartu: ~w-~w.~n', [Pemain, WarnaPilihan, JenisPilihan]),
            format('~w menyerukan UNI!~n', [Pemain]),
            
            deleteKartu(NomorUrut, Tangan, TanganBaru),
            retract(playerCard(Pemain, Tangan)),
            assertz(playerCard(Pemain, TanganBaru)),
            retract(activeCard(KartuAktif)),
            assertz(activeCard(KartuPilihan)),
            
            assertz(status_UNI(Pemain)),
            pindahGiliran(Pemain)
            
        ; 
            format('Kartu tidak valid! ~w mendapatkan 1 kartu penalti.~n', [Pemain]),
            tarik_kartu_penalti(1, Pemain),
            pindahGiliran(Pemain)
        )
    ; 
        format('Perintah tidak valid! ~w tidak memenuhi syarat UNI.~n', [Pemain]),
        format('~w mendapatkan 1 kartu penalti.~n', [Pemain]),
        tarik_kartu_penalti(1, Pemain),
        pindahGiliran(Pemain)
    ).

tangkap(Target) :-
    giliran(PemainAktif),
    ( PemainAktif == Target -> 
        write('Kamu tidak bisa menangkap dirimu sendiri!'), nl
    ; 
        playerCard(Target, TanganTarget),
        length(TanganTarget, L),
        
        ( (L =:= 1, \+ status_UNI(Target)) ->
            format('Tantangan berhasil! ~w tertangkap tidak menyerukan UNI.~n', [Target]),
            format('~w mendapatkan 2 kartu penalti.~n', [Target]),
            tarik_kartu_penalti(2, Target),
            pindahGiliran(Target)
        ;
            format('Tantangan gagal. ~w aman atau tidak melanggar aturan.~n', [Target]),
            format('~w mendapatkan 1 kartu penalti secara acak.~n', [PemainAktif]),
            tarik_kartu_penalti(1, PemainAktif)
        )
    ).

poin_kartu(kartu(_, J), Poin) :- integer(J), Poin = J, !.
poin_kartu(kartu(_, skip), 10) :- !.
poin_kartu(kartu(_, reverse), 10) :- !.
poin_kartu(kartu(_, drawTwo), 10) :- !.
poin_kartu(kartu(_, wild), 20) :- !.
poin_kartu(kartu(_, wildFour), 20) :- !.
poin_kartu(kartu(_, mimic), 20) :- !.
poin_kartu(_, 0).

hitung_poin([], 0).
hitung_poin([K|T], Total) :-
    poin_kartu(K, P),
    hitung_poin(T, Sub),
    Total is P + Sub.

kumpulkan_skor([], []).
kumpulkan_skor([Pemain|T], [[Poin, JmlKartu, Index, Pemain]|R]) :-
    playerCard(Pemain, Tangan),
    length(Tangan, JmlKartu),
    hitung_poin(Tangan, Poin),
    daftarPemain(Urutan),
    nth1(Index, Urutan, Pemain), 
    kumpulkan_skor(T, R).

tampil_kalkulasi_poin([]).
tampil_kalkulasi_poin([Pemain|T]) :-
    playerCard(Pemain, Tangan),
    hitung_poin(Tangan, Poin),
    ( Tangan == [] -> 
        format('~w: kartu habis = 0 poin~n', [Pemain])
    ; 
        format('~w: ~d poin~n', [Pemain, Poin])
    ),
    tampil_kalkulasi_poin(T).

tampil_pemenang([], _).
tampil_pemenang([[Poin, _, _, Pemain]|T], Peringkat) :-
    format('~d. ~w (~d poin)~n', [Peringkat, Pemain, Poin]),
    Next is Peringkat + 1,
    tampil_pemenang(T, Next).

endGame :-
    write('Permainan selesai!'), nl, nl,
    write('Berikut perhitungan poin sisa kartu:'), nl,
    daftarPemain(Urutan),
    tampil_kalkulasi_poin(Urutan),
    nl,
    
    kumpulkan_skor(Urutan, SkorBelumUrut),
    sort(SkorBelumUrut, SkorUrut), 
    
    write('Urutan pemenang:'), nl,
    tampil_pemenang(SkorUrut, 1),
    nl,
    SkorUrut = [[_, _, _, PemenangUtama] | _],
    format('Selamat, ~w menjadi pemenang!~n', [PemenangUtama]),
    retractall(gameMulai).