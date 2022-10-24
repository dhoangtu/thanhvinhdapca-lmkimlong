% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 46"
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
  \key c \major
  \time 2/4
  \partial 8 c8 |
  a g e8. f16 |
  g8 a r a |
  d, e f8. e16 |
  d8 g4 g8 |
  c c16 c g8 e |
  a4 r8 d,16 d |
  f8 g e d |
  c4 r8 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8
  <<
    {
      g16 g |
      e8 f f e |
      d4 r8 b'16 b |
      a8 a b g |
      c4 r8 \bar "|."
    }
    {
      e,16 e |
      c8 d d c |
      b4 r8 g'16 g |
      f8 f g f |
      e4 r8
    }
  >>
}

nhacPhanBa = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8
  <<
    {
      g8 |
      c e, g8. a16 |
      f4 d8 g
    }
    {
      e8 |
      d c e8. f16 |
      d4 c8 b
    }
  >>
  c2 ~ |
  c4 r8 \bar "|."
}

nhacPhanBon = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8 g8 |
  c, (d) e e |
  f4 d8 a' |
  g (f) e4 |
  e g f (e) |
  d4 r8
  <<
    {
      g8 |
      g8. g16 g8 g |
      a4. c8 |
      g4 e'8 c |
      d4 b8 b |
      c4 r8 \bar "|."
    }
    {
      b,8 |
      c8. d16 e8 e |
      f4. f8 |
      e4 g8 a |
      f4 g8 g |
      e4 r8
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Vỗ tay đi nào muôn dân hỡi,
      tán tụng Thiên Chúa, mau hò reo,
      vì Chúa, Đấng Tối cao khả úy,
      là đại vương thống trị địa cầu.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa ra lệnh truyền muôn dân nước,
      đến cùng suy bái quy phục ta,
      Ngài đã chiếm giúp cơ nghiệp đó,
      nở mặt Gia -- cóp kẻ yêu vì.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Chúa đi lên, ngàn câu hoan chúc,
      Chúa ngự lên giữa điệu kèn vang,
      Đàn hát hãy tấu vang mừng Chúa,
      và hòa ca kính Vua ta thờ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Đức Vua cai trị cả thế giới,
      tiến Ngài muôn khúc ca tuyệt luân,
      này Chúa vẫn thống trị vạn quốc,
      hằng ngự trên thánh ngài của Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Tiến lên, vương hầu muôn dân nước,
      với thần dân Chúa Ap -- ra -- ham,
      thủ lãnh khắp thế gian thuộc Chúa,
      Ngài thực cao sáng muôn muôn trùng.
    }
  >>
}

loiPhanHai = \lyricmode {
  Chúa tiến lên giữa tiếng reo mừng,
  Chúa tiến lên trong tiếng kèn vang.
}

loiPhanBa = \lyricmode {
  Thiên Chúa là Vua thống trị cả thế trần.
}

loiPhanBon = \lyricmode {
  Các trẻ em Do Thái trải áo trên đường và chúc tụng rằng:
  Hoan hô Con Vua Đa -- vít, chúc tụng Đấng ngự đến nhân danh Chúa.
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
        \line { \small "-t7 l /2TN: câu 1, 3, 4 + Đ.1" }
        \line { \small "-Kiệu Lá: câu 1, 2, 3, 4, 5 + Đ.3" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t6 /6PS: câu 1, 2, 3 + Đ.2" }
        \line { \small "-t7 /6PS: câu 1, 4, 5 + Đ.2" }
        \line { \small "-Chúa Thăng Thiên: câu 1, 3, 4 + Đ.1" }
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
