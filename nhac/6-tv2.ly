% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 2"
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
  a8 a a bf16 (a) |
  g4. g8 |
  a a f g16 (f) |
  c2 ~ |
  c8 c' d g, |
  bf8. bf16 bf8 c |
  f,4 r8 a |
  a a r d, |
  g8. g16 f8 f ~ |
  f d c4 \bar "||"
  r8 g'4 e8 |
  f4 r8 a |
  f8. f16 bf8 g |
  c4. a16 (g) |
  d8 d c g' |
  f2 ~ |
  f4 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key f \major
  \time 2/4
  \partial 4
  <<
    {
      c4 |
      d8. bf16 bf8 bf |
      bf4 g8 c |
    }
    {
      a4 |
      bf8. g16 g8 g |
      g4 e8 e |
    }
  >>
  f2 ~ |
  f4 r \bar "|."
}

nhacPhanBa = \relative c'' {
  \key f \major
  \time 2/4
  <<
    {
      c8 a bf (a)
    }
    {
      a8 f g (f)
    }
  >>
  <<
    {
      \voiceOne
      g2
    }
    \new Voice = "splitpart" {
      \voiceTwo
      e4. (d8)
    }
  >>
  \oneVoice
  <<
    {
      g8. c,16 d8 e |
      f2 \bar "|."
    }
    {
      c8. bf16 bf8 c |
      a2
    }
  >>
}

nhacPhanBon = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 f4 |
  <<
    {
      c'4. a8 |
      bf bf a4 |
      g2 ~ |
      g8 e c g' |
      f2 ~ |
      f4 r \bar "|."
    }
    {
      e4. f8 |
      g g f4 |
      c2 ~ |
      c8 c bf bf |
      a2 ~ |
      a4 r
    }
  >>
}

nhacPhanNam = \relative c' {
  \key f \major
  \time 2/4
  f4 e8 f |
  <<
    {
      g4 r8 a |
      a4. a8 |
      bf4 g8 e |
      f2 ~ |
      f4 r \bar "|."
    }
    {
      e4 r8 f |
      f4. f8 |
      g4 bf,8 c |
      a2 ~ |
      a4 r
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Sao chư dân náo động, muôn nước tính chuyện hão huyền,
      Vua chúa trần gian liên minh dấy loạn,
      chống đối Chúa và chống Đức Ki -- tô của Ngài.
      Chúng bảo nhau:
      xích xiềng họ ta bẻ gẫy,
      gông cùm họ nào quăng đi.
	    \tweak extra-offset #'(2 . 0)
      \markup { "đạt." \bold "Đ." }
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
	    Nơi cao sang cửu trùng, Thiên Chúa tức cười chê nhạo.
	    Đây Chúa bừng lên trong cơn nghĩa nộ,
	    quát mắng chúng, làm chúng khiếp run lên kinh hoàng.
	    Đó vị Vua, chính là người Ta sủng ái
	    sẽ ngự trị ở Si -- on.
	    \tweak extra-offset #'(2 . 0)
      \markup { "đạt." \bold "Đ." }
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
	    Đây Tân vương tiếp lời: Tôi xướng sắc phong Chúa truyền:
	    Đây chính là Con, nay Cha sinh hạ,
	    xin Cha ban trọn các quốc gia nên sản nghiệp.
	    Hãy thị oai, hãy dùng trượng sắt
	    đập chúng nát tựa mảnh sành đi Con.
	    \tweak extra-offset #'(2 . 0)
      \markup { "đạt." \bold "Đ." }
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
	    Quân vương Ta tuyển chọn, từ Si -- on Người thống trị
	    Rao sắc chỉ phong vương Thiên Chúa truyền:
	    Đây Con Cha, thực chính bữa nay Cha sinh
	    \tweak extra-offset #'(2 . 0)
      \markup { "hạ." \bold "Đ." }
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
	    Đây Tân vương tiếp lời: Tôi xướng sắc phong Chúa truyền:
	    Đây chính là Con, nay Cha sinh hạ,
	    xin Cha ban trọn các quốc gia nên sản
	    \tweak extra-offset #'(2 . 0)
      \markup { "nghiệp." \bold "Đ." }
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
	    Con xin, Ta sẽ tặng muôn nước để làm sản nghiệp
	    Nay khắp trần gian nên như lãnh địa,
	    Hãy quất chúng, và nghiến nát ra như mảnh
	    \tweak extra-offset #'(2 . 0)
      \markup { "sành." \bold "Đ." }
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
	    Bao quân vương cõi trần mau hãy biết điều tỉnh ngộ,
	    Mãy hãy thành tâm suy tôn Chúa Trời,
	    Hãy khiếp hãi, phục bái dưới chân ngai của
	    \tweak extra-offset #'(2 . 0)
      \markup { "Ngài." \bold "Đ." }
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
	    Sao vua quan thế trần mưu tính nhất tề nổi dậy
	    Toan chống lịa Đấng Chúa đã xức
	    \tweak extra-offset #'(2 . 0)
      \markup { "dầu." \bold "Đ." }
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      \override Lyrics.LyricText.font-shape = #'italic
	    Nơi cao sang cửu trùng, Thiên Chúa thấy vậy tức cười
	    Đây Chúa nhạo khinh mưu toan hão
	    \tweak extra-offset #'(2 . 0)
      \markup { "huyền." \bold "Đ." }
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
	    Đây Tân Vương tiếp lời: Tôi xướng sắc phong Chúa truyền
	    Đây chính là Con, nay Ta sinh
	    \tweak extra-offset #'(2 . 0)
      \markup { "hạ." \bold "Đ." }
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      \override Lyrics.LyricText.font-shape = #'italic
	    Con mau mau lấy trượng vung cánh để đập nát họ.
	    Mau nghiến họ tan ra như mảnh
	    \tweak extra-offset #'(2 . 0)
      \markup { "sành." \bold "Đ." }
    }
  >>
}

loiPhanHai = \lyricmode {
  Cha sẽ cho Con chư dân làm sản nghiệp.
}

loiPhanBa = \lyricmode {
  Phúc thay những ai vững niềm tin nơi Chúa.
}

loiPhanBon = \lyricmode {
  Lạy Chúa, xin chiếu ánh Thiên Nhan trên mình chúng con.
}

loiPhanNam = \lyricmode {
  Con là Con Cha, hôm nay Cha đã sinh hạ con.
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
  page-count = 2
}

\markup {
  \vspace #1
  %\fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
      }
    }
    \column {
      \left-align {
        \line { \small "-ngày 7/1: câu 5, 7 + Đ.1" }
        \line { \small "-t2 /2PS: câu 1, 2, 3 + Đ.2" }
        \line { \small "-Cn B /3PS: câu 8, 9, 10, 11 + Đ.3" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t6 /4PS: câu 4, 6, 7 + Đ.4" }
        \line { \small "Cầu khi bị bách hại: 1, 2, 7 + Đ.2" }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.5
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
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
    \override Lyrics.LyricSpace.minimum-distance = #0.8
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
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
    \override Lyrics.LyricSpace.minimum-distance = #0.8
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      instrumentName = \markup { \bold "Đ.3" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanBon
        }
      \new Lyrics \lyricsto beSop \loiPhanBon
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.5
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      instrumentName = \markup { \bold "Đ.4" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanNam
        }
      \new Lyrics \lyricsto beSop \loiPhanNam
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.8
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
