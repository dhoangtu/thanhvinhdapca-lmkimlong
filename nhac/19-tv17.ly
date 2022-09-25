% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 17"
  composer = "Lm. Kim Long"
  tagline = ##f
}

% mã nguồn cho những chức năng chưa hỗ trợ trong phiên bản lilypond hiện tại
% cung cấp bởi cộng đồng lilypond khi gửi email đến lilypond-user@gnu.org
% Đổi kích thước nốt cho bè phụ
notBePhu =
#(define-music-function (font-size music) (number? ly:music?)
   (for-some-music
     (lambda (m)
       (if (music-is-of-type? m 'rhythmic-event)
           (begin
             (set! (ly:music-property m 'tweaks)
                   (cons `(font-size . ,font-size)
                         (ly:music-property m 'tweaks)))
             #t)
           #f))
     music)
   music)

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
  \key c \major
  \time 2/4
  \partial 4 \tuplet 3/2 { a8 a b } |
  g4. e8 |
  c'4 \tuplet 3/2 { c8 a c } |
  b4 \tuplet 3/2 { a8 a d } |
  d4. b16 b |
  e8. e,16 \tuplet 3/2 { b'8 g b } |
  a4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key c \major
  \time 2/4
  \partial 8 e8 |
  a4
  <<
    {
      b |
      c4. b8 |
      e e
    }
    {
      gs,4 |
      a4. a8 |
      gs gs
    }
  >>
  <<
    {
      \voiceOne
      gs4
    }
    \new Voice = "splitpart" {
      \voiceTwo
      e8 (d)
    }
  >>
  \oneVoice
  <<
    {
      a'2 ~ |
      a4 \bar "|."
    }
    {
      c,2 ~ |
      c4
    }
  >>
}

nhacPhanBa = \relative c' {
  \key c \major
  \time 2/4
  \partial 8 e8 |
  <<
    {
      c'8. a16 \tuplet 3/2 { c8 a c } |
      b4 \tuplet 3/2 { d8 d e } |
      a,2 ~ |
      a4
    }
    {
      a8. f16 \tuplet 3/2 { a8 f a } |
      e4 \tuplet 3/2 { b'8 a gs } |
      a2 ~ |
      a4
    }
  >>
  \bar "|."
}

nhacPhanBon = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8 a16 f |
  e4
  <<
    {
      \tuplet 3/2 { a8 a b } |
      c4. d16 d |
      e8. e,16 \tuplet 3/2 { c'8 b gs } |
      a4 \bar "|."
    }
    {
      \tuplet 3/2 { a8 f e } |
      a4. f16 f |
      e8. c16 \tuplet 3/2 { e8 e e } |
      c4
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
	    Con yêu mến Ngài, lạy Chúa, sức mạnh của con,
	    Ngài là Núi đá, là thành lũy, là Đấng giải thoát con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Xin nên thuẫn khiên, lạy Chúa, lũy thành chở che.
      Ngài thực đáng kính, vừa cầu cứu Ngài đã giải thoát ngay.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Phong ba tử thần dồn lấp, thác ghềnh quỷ ma, dò tròng tứ phía,
      và màng lưới của tử thần bủa vây.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
	    Con kêu khấn Ngài, lạy Chúa, lúc gặp khó nguy.
	    Lời vọng tới Chúa, từ đền thánh Ngài đáp lại tiếng con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
	    Ôi minh xác thay Lời Chúa, lối Ngài thẳng ngay.
	    Ngài là thuẫn đỡ mọi kẻ đến gần Chúa để náu thân.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
	    Tôn vinh Đá Tảng, vạn tuế Đấng giải cứu tôi,
	    Dạo đàn hát xưỡng từ vạn quốc mà chúc tụng Thánh Danh.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
	    Tôn vinh Đá Tảng, vạn tuế Đấng giải cứu tôi.
	    Nhờ Ngài tiếp giúp mà hoàng đế được thắng trận vẻ vang.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
	    Quân vương đã lập, Ngài giúp thắng trận vẻ vang,
	    và hằng nghĩa thiết độ trì Đấng Ngài xức dầu tấn phong.
    }
  >>
}

loiPhanHai = \lyricmode {
  Ngợi khen Thiên Chúa là Đấng cứu độ tôi.
}

loiPhanBa = \lyricmode {
  Lạy Chúa là sức mạnh của con, con yêu mến Ngài.
}

loiPhanBon = \lyricmode {
  Lúc ngặt nghèo con kêu lên Chúa, kêu lên Chúa và Chúa đã nhậm lời.
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
  ragged-bottom = ##t
  print-page-number = ##f
}

\markup {
  \vspace #1
  \fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t7 c /18TN: câu 4,5,6 + Đ.2" }
        \line { \small "-t6 l /2TN: câu 1,3,4 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t7 l /33TN: câu 1,2,7 + Đ.3" }
      }
    }
  }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.8
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
    \override Lyrics.LyricSpace.minimum-distance = #0.8
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
