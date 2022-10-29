% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 66"
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
nhacPhanMot = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 c8 |
  a'4. bf8 |
  g8. f16 f8 d |
  d c4 f8 |
  f8. e16 f8 g |
  a a r f |
  bf4. bf8 |
  a8. g16 a8 bf |
  c4 d8 d |
  bf8. g16 g8 c |
  f,4 r8 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a8 |
  a c d, (f) |
  g4. c,8 |
  <<
    {
      g'8 g f e |
      f4 r8 \bar "|."
    }
    {
      bf8 bf bf c |
      a4 r8
    }
  >>
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 f8 |
  f f16 (g) d8 d |
  c4
  <<
    {
      e8 g |
      a4. a8 |
      a4 bf8 g |
      c bf g4
    }
    {
      c,8 e |
      f4. f8 |
      f4 g8 f |
      e d e4
    }
  >>
  f4 r8 \bar "|."
}

nhacPhanBon = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 f8 |
  d c c f16 (g) |
  a4 r8
  <<
    {
      a8 |
      f4 bf8 bf |
      g8. g16 g8 c
    }
    {
      f,8 |
      d4 g8 f |
      e8. e16 e8 e
    }
  >>
  f2 ~ |
  f4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Nguyện Chúa đoái thương ban muôn vàn ơn lành,
      Tôn nhan Ngài rầy xin chiếu sáng,
      Đường Chúa khắp trên địa cầu hay biết,
      các nước trông ơn Ngài cứu độ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Vì Chúa sẽ công minh cai trị địa cầu,
      muôn dân nào mừng vui hát xướng.
      ngài sẽ hiển minh trị vì muôn nước,
      thống lãnh muôn dân tộc cõi trần.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Lạy Chúa, chớ chi chư dân cảm tạ Ngài,
      Chư dân đồng thanh cảm mến CHúa.
      Nguyện Chúa khấng ban ngàn muôn ơn phúc,
      cõi đất hãy tôn sợ kính thờ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Thượng Đế, Chúa ta ban ân lộc muôn ngàn,
      bao hoa mầu trổ sinh khắp chốn.
      Nguyện Chúa khấng ban ngàn muôn ân phúc,
      cõi đất hãy tôn sợ kính thờ.
    }
  >>
}

loiPhanHai = \lyricmode {
  Xin Thiên Chúa dủ thương và chúc phúc cho đoàn con.
}

loiPhanBa = \lyricmode {
  Chư dân hãy xưng tụng Ngài,
  lạy Thiên Chúa, chư dân hết thảy hãy xưng tụng Ngài.
}

loiPhanBon = \lyricmode {
  Đất xinh mùa màng hoa trái,
  Chúa Trời, Chúa chúng ta ban muôn phúc lộc.
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
        \line { \small "-t6 /3MV: câu 1, 2, 4 + Đ.2" }
        \line { \small "-ngài 1/1: câu 1, 2, 3 + Đ.1" }
        \line { \small "-t7 l /17TN: câu 1, 2, 4 + Đ.2" }
        \line { \small "-Cn A /20TN: câu 1, 2, 3 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t4 /4PS: câu 1, 2, 4 + Đ.2" }
        \line { \small "-Cn C /6PS: câu 1, 2, 4 + Đ.2" }
        \line { \small "-sau mùa gặt: câu 1, 2, 4 + Đ.2 hoặc Đ.3" }
        \line { \small "-giảng T.Mừng: câu 1, 2, 4 + Đ.2 hoặc Đ.3" }
        \line { \small "-Cầu cho Hội Thánh: câu 1, 2, 4 + Đ.2" }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}
