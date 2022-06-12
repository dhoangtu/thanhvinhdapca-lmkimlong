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
  \key c \major
  \time 2/4
  \partial 4 c8. a16 |
  g4. f8 |
  f4 \tuplet 3/2 { f8 e f } |
  g4 \tuplet 3/2 { f8 f g } |
  a4 r8 a16 c |
  b8 e, f d |
  g4.
  <<
    {
      \voiceOne
      g16
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #2.5
      \tweak font-size #-2
      \parenthesize
      a16
    }
  >>
  \oneVoice
  \once \stemUp d, |
  f8 g e d |
  c4 \bar "||"
  
  \partial 4 r8 c |
  g'4 \tuplet 3/2 { fs8 fs g } | \break
  a4 \tuplet 3/2 { a8 g a } |
  c4 r8 b16 c |
  d8 e a, af |
  g4 \bar "||"
}

nhacPhanHai = \relative c' {
  \key c \major
  \time 2/4
  \partial 4 c4 |
  <<
    {
      g'2 |
      e8 e f f |
      d4. a'8 |
      a (b) a g |
      c2 ~ |
      c4 \bar "|."
    }
    {
      b,2 |
      c8 c d c |
      b4. c8 |
      f (d) f f |
      e2 ~ |
      e4
    }
  >>
}

nhacPhanBa = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4
  <<
    {
      g4 |
      e2 |
      d8 d d a' |
      g4. a8 |
      c2 ~ |
      c4 \bar "|."
    }
    {
      d,4 |
      c2 |
      b8 b b f' |
      e4. d8 |
      e2 ~ |
      e4
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4
  <<
    {
      g4 |
      a8 f e a |
      d,4 a'8 b |
      a4. g8 |
      c2 ~ |
      c4 \bar "|."
    }
    {
      e,4 |
      f8 d c c |
      b4 c8 g' |
      f4. f8 |
      e2 ~ |
      e4
    }
  >>
}

nhacPhanNam = \relative c'' {
  \key c \major
  \time 2/4
  \partial 4
  <<
    {
      g4 |
      g2 |
      a8 a a g |
      c2 |
      b8 b c c |
      a4.
    }
    {
      e4 |
      e2 |
      f8 f f f |
      e2 |
      g8 g a g |
      fs4.
    }
  >>
  <<
    {
      \voiceOne
      a16 (b)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      fs8
    }
  >>
  \oneVoice
  g2 ~ |
  g4 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Phúc thay ai không nghe theo lời khuyên lơn của bọn gian ác,
      không đứng trên đường lũ tội nhân,
      không ngồi chung với quân tham
	    \tweak extra-offset #'(4 . 0)
      \markup { "tàn." \italic "(tiếp)" }
      Họ luôn đặt niềm vui thú nơi lề luật Chúa
      và suy đi gẫm lại đêm ngày.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
	    Các chính nhân như cây ươm trồng bên suối
	    tùy mùa sinh trái,
	    Xanh tốt luôn chẳng có tàn phai,
	    công việc họ những luôn thịnh
	    \tweak extra-offset #'(2 . 0)
      \markup { "đạt." \bold "Đ." }
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
	    Lũ ác nhân tung bay như là tro trấu,
	    vật vờ theo gió theo lối đi dẫn tới diệt vong.
	    \markup { \italic \underline "Lối" }
	    hiền nhân Chúa luôn canh
	    \tweak extra-offset #'(2 . 0)
      \markup { "phòng." \bold "Đ." }
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa, ai theo Chúa sẽ được ánh sáng ban sự sống.
}

loiPhanBa = \lyricmode {
  Phúc thay người đặt niềm tin cậy nơi Chúa.
}

loiPhanBon = \lyricmode {
  Ta sẽ cho kẻ thắng trận ăn trái cây sự sống.
}

loiPhanNam = \lyricmode {
  Anh em hãy bắt chước Thiên Chúa như con cái dấu yêu của Ngài.
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
        \line { \small "Cầu khi bị bách hại: 1, 2, 7 + Đ" }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.8
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
