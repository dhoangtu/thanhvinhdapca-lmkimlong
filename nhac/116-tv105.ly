% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 105"
  composer = "Lm. Kim Long"
  tagline = ##f
}

% mã nguồn cho những chức năng chưa hỗ trợ trong phiên bản lilypond hiện tại
% cung cấp bởi cộng đồng lilypond khi gửi email đến lilypond-user@gnu.org
% in số phiên khúc trên mỗi dòng
#(define (add-grob-definition grob-name grob-entry)
     (set! all-grob-descriptions
           (cons ((@@ (lily) completize-grob-entry)
                  (cons grob-name grob-entry))
                 all-grob-descriptions)))

#(add-grob-definition
    'StanzaNumberSpanner
    `((direction . ,LEFT)
      (font-series . bold)
      (padding . 1.0)
      (side-axis . ,X)
      (stencil . ,ly:text-interface::print)
      (X-offset . ,ly:side-position-interface::x-aligned-side)
      (Y-extent . ,grob::always-Y-extent-from-stencil)
      (meta . ((class . Spanner)
               (interfaces . (font-interface
                              side-position-interface
                              stanza-number-interface
                              text-interface))))))

\layout {
    \context {
      \Global
      \grobdescriptions #all-grob-descriptions
    }
    \context {
      \Score
      \remove Stanza_number_align_engraver
      \consists
        #(lambda (context)
           (let ((texts '())
                 (syllables '()))
             (make-engraver
              (acknowledgers
               ((stanza-number-interface engraver grob source-engraver)
                  (set! texts (cons grob texts)))
               ((lyric-syllable-interface engraver grob source-engraver)
                  (set! syllables (cons grob syllables))))
              ((stop-translation-timestep engraver)
                 (for-each
                  (lambda (text)
                    (for-each
                     (lambda (syllable)
                       (ly:pointer-group-interface::add-grob
                        text
                        'side-support-elements
                        syllable))
                     syllables))
                  texts)
                 (set! syllables '())))))
    }
    \context {
      \Lyrics
      \remove Stanza_number_engraver
      \consists
        #(lambda (context)
           (let ((text #f)
                 (last-stanza #f))
             (make-engraver
              ((process-music engraver)
                 (let ((stanza (ly:context-property context 'stanza #f)))
                   (if (and stanza (not (equal? stanza last-stanza)))
                       (let ((column (ly:context-property context
'currentCommandColumn)))
                         (set! last-stanza stanza)
                         (if text
                             (ly:spanner-set-bound! text RIGHT column))
                         (set! text (ly:engraver-make-grob engraver
'StanzaNumberSpanner '()))
                         (ly:grob-set-property! text 'text stanza)
                         (ly:spanner-set-bound! text LEFT column)))))
              ((finalize engraver)
                 (if text
                     (let ((column (ly:context-property context
'currentCommandColumn)))
                       (ly:spanner-set-bound! text RIGHT column)))))))
      \override StanzaNumberSpanner.horizon-padding = 10000
    }
}

stanzaReminderOff =
  \temporary \override StanzaNumberSpanner.after-line-breaking =
     #(lambda (grob)
        ;; Can be replaced with (not (first-broken-spanner? grob)) in 2.23.
        (if (let ((siblings (ly:spanner-broken-into (ly:grob-original grob))))
              (and (pair? siblings)
                   (not (eq? grob (car siblings)))))
            (ly:grob-suicide! grob)))

stanzaReminderOn = \undo \stanzaReminderOff
% kết thúc mã nguồn

% Nhạc
nhacPhanMot = \relative c'' {
  \key f \major
  \time 2/4
  \partial 4. c8 f, g |
  a8. e16 e8 g |
  d4. c8 |
  c8 a'16 a f8 f |
  g2 |
  g8. a16 d,8 d |
  r8
  <<
    {
      \voiceOne
      g8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #-1.6
      \tweak font-size #-2
      \parenthesize
      g16
      \once \override NoteColumn.force-hshift = #-1.3
      \tweak font-size #-2
      \parenthesize
      g
    }
  >>
  \oneVoice
  g8 f16 (g) |
  a2 |
  bf8. a16 bf8 c |
  r8 g c a16 (g) |
  f4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 f16 (g) |
  d4 c |
  <<
    {
      a'4. g8
    }
    {
      f4. f8
    }
  >>
  <<
    {
      \voiceOne
      c'8 _(bf)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      e,4
    }
  >>
  \oneVoice
  <g e>4 |
  f2 ~ |
  f8 \bar "|."
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 c8 |
  <<
    {
      a'4. a8 |
      bf bf bf (a) |
      g4 d8 c |
      g'4. g8 |
      f2 ~ |
      f8
    }
    {
      f4. f8 |
      g g g (f) |
      c4 bf8 a |
      bf4. c8 |
      a2 ~ |
      a8
    }
  >>
  \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hãy tạ ơn Chúa vì Ngài nhân từ,
      ngàn đời Chúa vẫn trọn tình thương.
      Ai sẽ tường thuật huân công của Chúa,
      Ai sẽ công bố lời tán dương Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Sống đời công chính là người nhân hậu,
      thực hành đức nghĩa mọi thời luôn.
      Xin nhớ phận này \markup { \underline "khi" }
      \markup { \underline "thương" } dân của Chúa.
      Xin ngự thăm viếng, giải thoát con cùng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Hãy làm con thấy tận tường phúc lộc
      tặng người Chúa đã tuyển chọn đây.
      Cho hãnh diện vì cơ ngơi của Chúa,
      cho được vui sướng cùng với dân Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Giống bậc tiên bối, nhiều lần lỗi phạm,
      làm điều bất chihs và tàn hung,
      ngay lúc họ còn bên Ai Cập đó,
      chẳng hề suy thấu kiệt tác của Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Chúng vội quên lãng mọi việc Chúa làm,
      chẳng đợi các huấn lệnh Ngài ban.
      Buông thả dục vọng ngay nơi rừng vắng,
      Toan thử thách Chúa ở giữa hoang địa.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Lúc ở Hô -- rép, họ đà đúc tượng,
      phục lạy kính bái hình bòn con.
      Thiên Chúa rạng ngời nay đem đổi lấy
      pho tượng con thú gặm cỏ nương đồng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Bởi họ quên Chúa là Vị cứu độ,
      Ngài từng xúc tiến ngàn kỳ công,
      bao dấu diệu kỳ bên Ai  Cập đó,
      bao điều kinh hãi ở giữa biển Hồng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa từng toan tính tận diệt lũ họ,
      nhược bằng chẳng có lời Mô -- sê,
      ngay trước mặt Ngài đem thân cản lối,
      Xin Ngài nguôi bớt, đừng giết dân Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Bởi họ chung sống lộn cùng dân ngoại,
      học đòi chúng hết mọi hành vi,
      không quyết diệt trừ bao dân tộc đó,
      bao điều kinh hãi ở giữa biển Hồng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Bởi họ chung sống lộn cùng dân ngoại,
      học đòi chúng hết mọi hành vi,
      tôn kính tượng thần chư dân sùng bái,
      đây là cạm bẫy họ mắc chân vào.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      Giết cả con cái của họ tế thần.
      Vì vậy Chúa đã thịnh nộ lên.
      Dân Chúa tuyển chọn nay trêu giận Chúa,
      gia nghiệp của Chúa làm Chúa kinh nhờm.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "12."
      \override Lyrics.LyricText.font-shape = #'italic
      Những hành vi đó làm họ uế tạp,
      Việc họ có khác ngoại tình đâu.
      Dân Chúa tuyển chọn nay trêu giận Chúa,
      gia nghiệp của Chúa làm Chúa kinh nhờm.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "13."
      Đã nhiều khi Chúa định giải cứu họ,
      mà họ cứ dấy loạn, bội ân.
      Khi Chúa nhìn họ truân chuyên ngàn nỗi,
      nghe họ kêu cứu, Ngài vẫn thương tình.
    }
  >>
}

loiPhanHai = \lyricmode {
  Hãy cảm tạ Chúa vì Chúa nhân từ.
}

loiPhanBa = \lyricmode {
  Lạy Chúa, xin nhớ đến chúng con bởi lòng tình dân Ngài.
}

% Dàn trang
\paper {
  #(set-paper-size "a5")
  top-margin = 3\mm
  bottom-margin = 3\mm
  left-margin = 3\mm
  right-margin = 3\mm
  indent = #0
  #(define fonts
	 (make-pango-font-tree "Deja Vu Serif Condensed"
	 		       "Deja Vu Serif Condensed"
			       "Deja Vu Serif Condensed"
			       (/ 20 20)))
  print-page-number = ##f
  ragged-bottom = ##t
  page-count = 2
}

\markup {
  \vspace #1
  %\fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
        \line { \small "-t5 c /5TN: câu 2, 10, 11 + Đ.2" }
        \line { \small "-t7 c /5TN: câu 4, 6, 7 + Đ.1" }
        \line { \small "-t5 l /12TN: câu 1, 2, 3 + Đ.1" }
        \line { \small "-t6 l /13TN: câu 1, 2, 3 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t2 l /17TN: câu 6, 7, 8 + Đ.1" }
        \line { \small "-t4 l /18TN: câu 4, 5, 7, 8 + Đ.2" }
        \line { \small "-t2 l /20TN: câu 9, 12, 13 + Đ.2" }
        \line { \small "-t5 /4MC: câu 6, 7, 8 + Đ.2" }
        \line { \small "-t.Mục tử: câu 6, 7, 8 + Đ.2" }
      }
    }
  %}
}

\score {
  <<
    \new Staff <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanMot
        }
      \new Lyrics \lyricsto beSop \loiPhanMot
    >>
  >>
  \layout {
    \override Lyrics.LyricSpace.minimum-distance = #1
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.1" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanHai
        }
      \new Lyrics \lyricsto beSop \loiPhanHai
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.6
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.2" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanBa
        }
      \new Lyrics \lyricsto beSop \loiPhanBa
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
