% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 32"
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
  c8 b16 (c) d8 c |
  g4 e8 f |
  g a d,16 (f) e8 |
  c2 |
  c8 g' a (g) |
  e4. c'8 |
  %\once \slurDashed
  \once \phrasingSlurDashed
  b \(c\) d (e) |
  d2 |
  b8. c16 b8 e, |
  a a r d, |
  f f g b, |
  c4 \bar "||"
}

nhacPhanHai = \relative c' {
  \key c \major
  \time 2/4
  \partial 4
  c8 (d) |
  e4. e8 |
  e f d c |
  <<
    {
      g'4 a8 b |
      c2 \bar "|."
    }
    {
      b,4 d8 d |
      e2
    }
  >>
}

nhacPhanBa = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4
  g8 g |
  c, (d)
  <<
    {
      e d |
      g4 e8 e |
      a4. g8 |
      d' c b4 |
      c2 ~ |
      c4 r \bar "|."
    }
    {
      c,8 c |
      b4 c8 c |
      f4. e8 |
      f fs g4 |
      e2 ~ |
      e4 r
    }
  >>
}

nhacPhanBon = \relative c' {
  \key c \major
  \time 2/4
  \partial 4
  c8 (d) |
  e4. e8 |
  d (
  <<
    {
      e) g a |
      a2 |
      a8 a g (a) |
      c2 ~ |
      c4 r \bar "|."
    }
    {
      c,8) e f |
      f2 |
      f8 f e (d) |
      e2 ~ |
      e4 r
    }
  >>
}

nhacPhanNam = \relative c' {
  \key c \major
  \time 2/4
  \partial 4
  c8 (d) |
  e8. e16 f8 d |
  g4.
  <<
    {
      a8 |
      g g a (b) |
      c2 \bar "|."
    }
    {
      f,8 |
      e e f (d) |
      e2
    }
  >>
}

nhacPhanSau = \relative c' {
  \key c \major
  \time 2/4
  \partial 4
  e8 (g) |
  a4 r8
  <<
    {
      c8 |
      c d c a |
      b2 |
      r8
    }
    {
      a |
      a b a f |
      e2 |
      r8
    }
  >>
  <<
    {
      \voiceOne
      b'16 (d)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      gs,8
    }
  >>
  \oneVoice
  <<
    {
      c8 c |
      c2 ~ |
      c4 r \bar "|."
    }
    {
      a8 f |
      e2 ~ |
      e4 r
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "12."
      \override Lyrics.LyricText.font-shape = #'italic
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "13."
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "14."
      \override Lyrics.LyricText.font-shape = #'italic
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "15."
      
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "16."
      \override Lyrics.LyricText.font-shape = #'italic
      
    }
  >>
}

loiPhanHai = \lyricmode {
  
}

loiPhanBa = \lyricmode {
  
}

loiPhanBon = \lyricmode {
  
}

loiPhanNam = \lyricmode {
  
}

loiPhanSau = \lyricmode {
  
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
  page-count = 3
}

\markup {
  \vspace #1
  %\fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
        \line { \small "-ngày 21/12: câu 3, 9, 14 + Đ.2" }
        \line { \small "-Cn A /2MV: câu 4, 12, 16 + Đ.1" }
        \line { \small "-vọng PS (b.1): 4, 5, 10, 16 + Đ.5" }
        \line { \small "-t3 /PS: câu 3, 12, 16 + Đ.5" }
        \line { \small "-t7 /2PS: câu 1, 4, 12 + Đ.5" }
        \line { \small "-Cn A /5PS: câu 1, 3, 12 + Đ.5" }
        \line { \small "-t6 l /6TN: câu 8, 10, 11 + Đ.1" }
        \line { \small "-t5 l /8TN: câu 4, 5, 7 + Đ.3" }
        \line { \small "-t2 l /12TN: câu 10, 13, 16 + Đ.4" }
        \line { \small "-t4 l /14TN: câu 3, 8, 12 + Đ.4" }
        \line { \small "-Cn C /19TN: câu 2, 13, 15 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t6 c /21TN: câu 1, 3, 8 + Đ.5" }
        \line { \small "-t7 c /21TN: câu 10, 12, 14 + Đ.1" }
        \line { \small "-t4 c /22TN: câu 10, 11, 14 + Đ.1" }
        \line { \small "-t4 c /24TN: câu 3, 4, 15 + Đ.1" }
        \line { \small "-t6 c /28TN: câu 1, 4, 10 + Đ.1" }
        \line { \small "-Cn B /29TN: câu 4, 12, 16 + Đ.4" }
        \line { \small "-C.Ba Ngôi B: 4, 6, 12, 18 + Đ.1" }
        \line { \small "-nhận dự tòng: 4, 10, 12, 16 + Đ.1 hoặc Đ.4" }
        \line { \small "-khấn dòng: 3, 4, 9, 12, 14 + Đ.1" }
        \line { \small "-Thánh Tâm (NL): 1, 4, 9, 12, 14 + Đ.5" }
        \line { \small "-lễ Hôn Phối: câu 10, 14, 16 + Đ.5" }
        \line { \small "-" }
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
