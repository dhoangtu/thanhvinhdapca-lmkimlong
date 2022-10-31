% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 84"
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
  \key g \major
  \time 2/4
  \partial 4 g8 a16 fs |
  g8 a e e |
  d4. d16 d |
  d8 g fs a |
  b4 r8 c |
  b8. e,16 e8 g |
  a4. a8 |
  d d b16 (a) d8 |
  g,4 \bar "||"
}

nhacPhanHai = \relative c' {
  \key g \major
  \time 2/4
  \partial 4 d4 |
  <<
    {
      b'4. a8 |
      a b a g |
      c2 ~ |
      c8 a b c |
      d2 |
      fs,8. g16 a8 b |
      d,4
    }
    {
      g4. g8 |
      fs g fs f! |
      e2 ~ |
      e8 fs g a |
      fs2 |
      d8. e16 d8 c |
      b4
    }
  >>
  <<
    {
      \voiceOne
      a'8 b16 (a)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      c,8 c
    }
  >>
  \oneVoice
  <g' b,>4 \bar "|."
}

nhacPhanBa = \relative c' {
  \key g \major
  \time 2/4
  \partial 4 d4 |
  <<
    {
      b'4. a8 |
      a b b g |
      c2 ~ |
      c8 a c d
    }
    {
      g,4. g8 |
      fs g g f! |
      e2 ~ |
      e8 fs a fs
    }
  >>
  g2 ~ |
  g4 \bar "|."
}

nhacPhanBon = \relative c' {
  \key g \major
  \time 2/4
  \partial 4 d4 |
  <<
    {
      b'4 c8 b |
      a4. c8 |
      d4 r8 d, |
      a' a a4 |
      g2 ~ |
      g4 \bar "|."
    }
    {
      g4 a8 g |
      fs4. e8 |
      fs4 r8 d |
      c c d4 |
      b2 ~ |
      b4
    }
  >>
}

nhacPhanNam = \relative c' {
  \key g \major
  \time 2/4
  \partial 4 d8 g |
  <<
    {
      b4 \tuplet 3/2 { a8 b c } |
      d4 r8 b16 c |
      a4 \tuplet 3/2 { a8 b a } |
      g4 \bar "|."
    }
    {
      g4 \tuplet 3/2 { fs8 g a } |
      b4 r8 g16 a |
      fs4 \tuplet 3/2 { e8 d c } |
      b4
    }
  >>
}

nhacPhanSau = \relative c' {
  \key g \major
  \time 2/4
  \partial 4 d8
  <<
    {
      b'8 |
      b4. g8 |
      g c e, (g) |
      a4 a8 a |
      g4 \bar "|."
    }
    {
      g8 |
      g4. fs8 |
      e d c (e) |
      d4 d8 c |
      b4
    }
  >>
}

nhacPhanBay = \relative c'' {
  \key g \major
  \time 2/4
  \partial 4 g4 |
  d d8
  <<
    {
      d'8 |
      d c4 a8
    }
    {
      b8 |
      b a4 fs8
    }
  >>
  g2 ~ |
  g4 \bar "|."
}

nhacPhanTam = \relative c'' {
  \key g \major
  \time 2/4
  \partial 4 g8 g |
  e4 a8 (g) |
  d4.
  <<
    {
      a'8 |
      b b b (a)
    }
    {
      d,8 |
      g g g (fs)
    }
  >>
  g4 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Xin Chúa dủ thương thánh địa của Ngài,
      và phục hồi cho nhà Gia -- cóp.
      Thứ tha tội tình của dân,
      vùi lấp tất cả lỗi lầm.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Xin Chúa dủ thương cứu độ dân Ngài,
      và dìu về, xin đừng hận nữa.
      Lẽ đâu Ngài giận khôn thôi,
      và cứ mãi nuôi nghĩa nộ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Vâng, chính Ngài cho chúng con sinh tồn,
      và làm thần dân Ngài vui sướng.
      Chúa mau biểu lộ tình thương và kíp xuống ơn cứu độ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Xin Chúa biểu dương nghĩa ân của Ngài,
      làm tỏ rạng ơn Ngài giải cứu,
      Cứu ai hằng sợ Tôn Danh,
      Dọi chiếu ánh vinh hiển Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Tôi lẳng lặng nghe Chúa nay ban truyền
      lời chào bình an tặng dân Chúa.
      Cứu ai hằng sợ Tôn Danh,
      Dọi chiếu ánh vinh hiển Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Ân nghĩa và công đức nay tao ngộ,
      Hòa bình đẹp duyên cùng công chính.
      Đất nay nảy mầm công minh,
      thành tín giáng lâm bởi trời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Vâng, chính Ngài ban phúc ân dư đầy,
      và ruộng đồng nở rộ hoa trái.
      Tín trung rầy làm tiền phong
      mở lối bước chân của Ngài.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa, xin cho chúng con được thấy tình thương của Chúa,
  Và ban ơn cứu độ cho chúng con.
}

loiPhanBa = \lyricmode {
  Lạy Chúa, xin cho chúng con được thấy tình thương của Ngài.
}

loiPhanBon = \lyricmode {
  Này đây Chúa chúng ta sẽ đến và cứu thoát chúng ta.
}

loiPhanNam = \lyricmode {
  Trời cao hỡi, nào gieo sương xuống.
  Mây hãy mưa, mưa Đấng cứu độ.
}

loiPhanSau = \lyricmode {
  Điều Chúa phán là lời chúc bình an cho dân Ngài.
}

loiPhanBay = \lyricmode {
  Ân tình và tín nghĩa nay tương phùng.
}

loiPhanTam = \lyricmode {
  Vinh quang Ngài chiếu dọi trên đất nước chúng ta.
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
        \line { \small "-Cn B /2MV: câu 5, 6, 7 + Đ.1" }
        \line { \small "-t2 /2MV: câu 5, 6, 7 + Đ.3" }
        \line { \small "-t4 /3MV: câu 5, 6, 7 + Đ.4" }
        \line { \small "-t6 l /2TN: câu , 6, 7 + Đ.6" }
        \line { \small "-t5 l /10TN: câu 5, 6 ,7 + Đ.7" }
        \line { \small "-t7 c /13TN: câu 5, 6, 7 + Đ.7" }
        \line { \small "-Cn B /15TN: câu 5, 6, 7 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-t3 c /16TN: câu 1, 2, 3 + Đ.2" }
        \line { \small "-Cn A /19TN: câu 5, 6, 7 + Đ.1" }
        \line { \small "-t3 l /20TN: câu 5, 6, 7 + Đ.5" }
        \line { \small "-t7 c /20TN: câu 5, 6, 7 + Đ.5" }
        \line { \small "-t3 c /29TN: câu 5, 6, 7 + Đ.5" }
        \line { \small "-cầu bình an: câu 5, 6, 7 + Đ.5" }
        \line { \small "-mọi nhu cầu: câu 5, 6, 7 + Đ.1" }
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
      instrumentName = \markup { \bold "Đ.7" }} <<
        \clef treble
        \new Voice = beSop {
          \nhacPhanTam
        }
      \new Lyrics \lyricsto beSop \loiPhanTam
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
