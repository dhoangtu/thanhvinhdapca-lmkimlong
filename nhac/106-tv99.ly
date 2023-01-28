% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 99"
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
  b8. e,16 g8 e |
  d4 \tuplet 3/2 { d8 g a } |
  b4. g16 g |
  c8. c16 a8 c |
  d4 \tuplet 3/2 { c8 c b } |
  a8. d,16 \tuplet 3/2 { b'8 b a } |
  g2 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key g \major
  \time 2/4
  <<
    {
      d4 b8 b |
      c4. c8 |
      a b a4
    }
    {
      b4 g8 g |
      a4. a8 |
      fs g fs4
    }
  >>
  g2 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key g \major
  \time 2/4
  <<
    {
      b4. g8 |
      c c a4 ~ |
      a8 d d fs, |
      g2 \bar "|."
    }
    {
      g4. e8 |
      a a fs4 ~ |
      fs8 fs e d |
      b2
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key g \major
  \time 2/4
  g4 fs8 g |
  e4 d8 d |
  <<
    {
      b'8. b16 a8 d
    }
    {
      g,8. g16 fs8 fs
    }
  >>
  g2 \bar "|."
}

nhacPhanNam = \relative c'' {
  \key g \major
  \time 2/4
  b8 b e, g |
  a4.
  <<
    {
      b8 |
      a a
    }
    {
      g8 |
      fs fs
    }
  >>
  <<
    {
      \voiceOne
      d'8 b16 (a)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      fs8 fs
    }
  >>
  \oneVoice
  g2 \bar "|."
}

nhacPhanSau = \relative c'' {
  \key g \major
  \time 2/4
  <<
    {
      d4. b8 |
      a4. g8 |
      g b e, d |
      g4. a8 |
      b2 ~ |
      b4 r \bar "|."
    }
    {
      b4. g8 |
      fs4. f!8 |
      e d c c |
      b4. d8 |
      g2 ~ |
      g4 r
    }
  >>
}

nhacPhanBay = \relative c'' {
  \key g \major
  \time 2/4
  b8 b a g |
  e8. e16 e8 a |
  d,2 |
  r8
  <<
    {
      d'8 b c |
      a8. a16
    }
    {
      b8 g e |
      fs8. fs16
    }
  >>
  <<
    {
      \voiceOne
      d'8 b16 (a)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      fs8 fs
    }
  >>
  \oneVoice
  g2 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hỡi toàn thể địa cầu, hãy tung hô Chúa,
      phụng thờ Chúa với niềm hỉ hoan,
      Cất tiếng reo vui vào trước thánh nhan Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Hãy thành khẩn tin nhận Ngài là Thiên Chúa,
      tạo thành ta, ta là dân Chúa,
      giống lớp chiên con, Ngài dẫn dắt trong đàn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Hãy vào cửa điện vàng mà tri ân Chúa,
      vào hành lang với lời ngợi khen,
      cảm mến tri ân và kính chúc danh Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Bởi vì ở nơi ngài đầy lòng nhân ái,
      ngàn đời Chúa vẫn trọn tình thương,
      mãi tới thiên thu ngài vẫn tín trung hoài.
    }
  >>
}

loiPhanHai = \lyricmode {
  Hãy tung hô Chúa, hỡi toàn thể địa cầu.
}

loiPhanBa = \lyricmode {
  Hãy vào trước Thánh Nhan giữa tiếng hò reo.
}

loiPhanBon = \lyricmode {
  Ta là dân Ngài, là đoàn chiên tay Ngài dẫn đạo.
}

loiPhanNam = \lyricmode {
  Chính Chúa dựng nên ta, ta là sở hữu của Ngài.
}

loiPhanSau = \lyricmode {
  Phúc cho ai được mời đến dự tiệc Chiên Thiên Chúa.
}

loiPhanBay = \lyricmode {
  Nếu các con thi hành điều Thầy phán dạy,
  các con sẽ là bạn hữu của Thầy.
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
        \line { \small "-ngày 5/1: cả 4 câu + Đ.1" }
        \line { \small "-t5 c /8TN: cả 4 câu + Đ.2" }
        \line { \small "-Cn A /11TN: câu 1, 2, 4 + Đ.3" }
        \line { \small "-t6 l /22TN: cả 4 câu + Đ.2" }
        \line { \small "-t3 c /24TN: cả 4 câu + Đ.3" }
        \line { \small "-t7 l /24TN: cả 4 câu + Đ.2" }
        \line { \small "-t2 c /29TN: cả 4 câu + Đ.4" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-t5 c /34TN: cả 4 câu + Đ.5" }
        \line { \small "-Cn C /4PS: câu 1, 2, 4 + Đ.3" }
        \line { \small "-t7 /5PS: câu 1, 2, 4 + Đ.3" }
        \line { \small "-Truyền chức: cả 4 câu + Đ.6" }
        \line { \small "-Khấn dòng: cả 4 câu + Đ.6" }
        \line { \small "-Hiệp nhất Kitô hữu: cả 4 câu + Đ.3" }
        \line { \small "-Phát triển các dân: cả 4 câu + Đ.3" }
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
