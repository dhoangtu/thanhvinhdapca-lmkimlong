% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 23"
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
  \partial 4 a16 (c) f,8 |
  d8. c16 d8 f16 (g) |
  a8 f a16 (c) a8 |
  g4. f8 bf8. bf16 g8 g16 (bf) |
  c2 ~ |
  c4 a8. a16 |
  g8 c e, (f) |
  g4. f8 |
  bf8. bf16 g8 g |
  c4 r8 f, |
  bf8. a16 g8 c |
  f,4 r8 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      a16 a |
      a4. f8 |
      f a g e |
      f2 ~ |
      f4 \bar "|."
    }
    {
      f16 f |
      f4. d8 |
      d f bf c |
      a2 ~ |
      a4
    }
  >>
}

nhacPhanBa = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      a8 |
      a8. a16 f8 f
      bf4 r8 g |
      c8. c16 e,8 e |
      f4 \bar "|."
    }
    {
      f8 |
      f8. f16 ef8 ef |
      d4 r8 f |
      e8. d16 c8 c |
      a4
    }
  >>
}

nhacPhanBon = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 c8 |
  <<
    {
      a'8. a16 f8 f |
      bf4. bf8 |
      g4 g8 c
    }
    {
      f,8. f16 ef8 ef |
      d4. d8 |
      e4 e8 e
    }
  >>
  f4 \bar "|."
}

nhacPhanNam = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      a8 |
      a8. f16 f8 bf |
      bf4. bf8 |
      a g4 c8
    }
    {
      f,8 |
      f8. ef16 d8 f |
      g4. g8 |
      f e4 e8
    }
  >>
  f4 \bar "|."
}

nhacPhanSau = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      a8 |
      a8. 16
    }
    {
      f8 |
      f8. f16
    }
  >>
  <<
    {
      \grace g16 (c8) e
    }
    {
      e,8 c
    }
  >>
  <f a,>4 \bar "|."
}

nhacPhanBay = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a8 \bar "|"
  d, (e) f (g) \bar "|"
  a4. g8 \bar "|"
  a c c (a) c d \bar "|"
  d4. f,8 \bar "|"
  g g g (f) \bar "|"
  e4. g8 \bar "|"
  g4 e8 f e (d) \bar "|"
  d4 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Chúa chủ trị toàn thể trái đất và khắp dương gian,
      vạn dân muôn vật ở đó do tay Ngài tác tạo nên,
      đặt móng giữa lòng biển lớn củng cố giữa sông nước rộng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Hỏi ai người được trèo lên núi của Chúa cao quang,
      và ai cự ngụ đền thánh?
      Ai tay sạch với lòng thanh,
      chẳng mê theo bả phù vân,
      chẳng tính mưu đồ phỉnh gạt.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Chính họ được là được Thiên Chúa rộng rãi thi ân,
      được Chúa Cứu độ thưởng phúc.
      Đó chính là những tử tôn, dòng dõi những kẻ tìm Chúa,
      tìm kiếm Chúa Gia -- cop hoài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Hỡi cửa đền, cửa đền cổ kính hãy cất cao lên,
      để Vua vinh hiển ngự quá.
      Vua vinh hiển đó là ai?
      Là Chúa thế lực quyền uy, thật dũng mãnh khi xuất trận.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Hỡi cửa đền, cửa đền cổ kính hãy cất cao lên,
      để Vua vinh hiển ngự quá.
      Vua vinh hiển đó là ai?
      Là chính Chúa Tể càn khôn, là chính Đước Vua hiển trị.
    }
  >>
}

loiPhanHai = \lyricmode {
  Chúa sẽ đến, Ngài là Đức Vua hiển vinh.
}

loiPhanBa = \lyricmode {
  Nhưng vua hiển vinh là ai?
  Là chính Chúa Tể càn khôn.
}

loiPhanBon = \lyricmode {
  Lạy Chúa, đây là dòng dõi những kẻ tìm kiếm Ngài.
}

loiPhanNam = \lyricmode {
  Chính Chúa làm chủ trái đất với muôn vật muôn loài.
}

loiPhanSau = \lyricmode {
  Nhưng Vua vinh hiển là ai?
}

loiPhanBay = \lyricmode {
  Các trẻ Do -- thái cầm cành ô -- liu đi đón Chúa
  và hân hoan ca tụng: Hoan hô trên các tầng trời.
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
}

\markup {
  \vspace #1
  %\fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
        \line { \small "-Cn A /4MV: câu 1, 2, 3 + Đ.1" }
        \line { \small "-t3 c /3TN: câu 4, 5 + Đ.2" }
        \line { \small "-ngày 20/12: câu 1, 2, 3 + Đ.1" }
        \line { \small "-t3 l /3TN: câu 1, 2, 3 + Đ.3" }
        \line { \small "-t5 c /22TN: câu 1, 2, 3 + Đ.4" }
        \line { \small "-t6 c /29TN: câu 1, 2, 3 + Đ.3" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t2 c /34TN: câu 1, 2, 3 + Đ.3" }
        \line { \small "-lễ Lá: câu 1, 4, 5 + Đ.6" }
        \line { \small "-t7 l /29TN: câu 1, 2, 3 + Đ.3" }
        \line { \small "-t2 c /32TN: câu 1, 2, 3 + Đ.3" }
        \line { \small "-t2 l /33TN: câu 1, 2, 3 + Đ.3" }
        \line { \small "-khấn dòng: câu 1, 2, 3 + Đ.3" }
        \line { \small "-ngày 2/2: câu 4, 5 + Đ.5" }
        \line { \small "-ngày 1/11: câu 1, 2, 3 + Đ.3" }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.5
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

\score {
  <<
    \new Staff \with {
      \remove "Time_signature_engraver"
      instrumentName = \markup { \bold "Đ.5" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanSau
        }
      \new Lyrics \lyricsto beSop \loiPhanSau
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
      instrumentName = \markup { \bold "Đ.6" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanBay
        }
      \new Lyrics \lyricsto beSop \loiPhanBay
    >>
  >>
  \layout {
    indent = 10
    \override Lyrics.LyricSpace.minimum-distance = #0.6
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \set Score.defaultBarType = ""
    ragged-last = ##f
  }
}

