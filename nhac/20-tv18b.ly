% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 18B"
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
  \partial 4 g8. g16 |
  b8 fs e4 ~ |
  e8 e c' a |
  d4 d8. c16 |
  b8 e a,4 ~ |
  a8 fs e d |
  g4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key g \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      b'4 g8 g |
      c8. a16 a8 a |
      d2 ~ |
      d4 \bar "|."
    }
    {
      g,4 g8 f! |
      e8. c16 e8 g |
      fs2 ~ |
      fs4
    }
  >>
}

nhacPhanBa = \relative c'' {
  \key g \major
  \time 2/4
  \partial 8
  <<
    {
      d8 |
      b8. g16 c8 c |
      a4
    }
    {
      b8 |
      g8. f!16 e8 a |
      d,4
    }
  >>
  <<
    {
      \voiceOne
      e8 fs16 (e)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      c8 c
    }
  >>
  \oneVoice
  <<
    {
      d4. g8 |
      g4 \bar "|."
    }
    {
      c,4. c8 |
      b4
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key g \major
  \time 2/4
  \partial 8
  <<
    {
      b8 |
      b8. a16
    }
    {
      g8 |
      g8. g16
    }
  >>
  <<
    {
      \voiceOne
      d'8 b16 (a)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      fs8 g
    }
  >>
  \oneVoice
  <e c>4
  <<
    {
      \voiceOne
      e16 (g) e8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      c8 c
    }
  >>
  \oneVoice
  <<
    {
      d4. g8 |
      g4 \bar "|."
    }
    {
      c,4. c8 |
      b4
    }
  >>
}

nhacPhanNam = \relative c' {
  \key g \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      b'4 d8 d |
      g, a4 e8 |
      b'4. a8 |
      g4 \bar "|."
    }
    {
      g4 fs8 fs |
      e d4 c8 |
      d4. c8 |
      b4
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Mệnh lệnh Cháu thiện toàn, bồi dưỡng hồn vía,
      Thánh chỉ Ngài vững bền giúp ta học khôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Lề luật Chúa chân thực sảng khoái lòng trí,
      Huấn lệnh Ngài sáng ngời chiếu soi thị quan.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Lòng sợ Chúa thanh vẹn bền vững ngàn kiếp,
      Phán định Ngài xác thực mãi luôn thẳng ngay.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Thực là quý hơn vàng, vàng khối thuần chất,
      giống như mật thắm ngọt tiết tự tàng ong.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Này đầy tớ của Ngài đà gắng ohjc kỹ,
      bởi trung thành giữ gìn, ích lợi ngàn muôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Mà nào có ai tường được hết lầm lỗi,
      nếu đôi lần lỡ phạm, xin Ngài niệm tha.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Ngài gìn giữ con đừng tự kiêu tự đắc,
      tránh khỏi lầm lỗi ngày sẽ thanh vẹn luôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Lời miệng lưỡi con nài vọng thấu về Chúa,
      Chúa vui lòng chấp nhận, cứu độ hồn con.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lời Chúa là thần trí và là sự sống.
}

loiPhanBa = \lyricmode {
  Giới răn của Chúa chính trực làm hoan lạc tâm can.
}

loiPhanBon = \lyricmode {
  Phán quyết của Chúa chân thực, hết thảy đều công minh.
}

loiPhanNam = \lyricmode {
  Lạy Chúa, Chúa có lời ban sự sống muôn đời.
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
        \line { \small "-t7 l /1TN: câu 1, 2, 3, 8 + Đ.1" }
        \line { \small "-Cn C /3TN: câu 1, 2, 3, 8 + Đ.1" }
        \line { \small "-t2 c /7TN: câu 1, 2, 3, 8 + Đ.1" }
        \line { \small "-t7 l /8TN: câu 1, 2, 3, 4 + Đ.2" }
        \line { \small "-t5 c /13TN: câu 1, 2, 3, 4 + Đ.2" }
        \line { \small "-t6 l /16TN: câu 1, 2, 3, 5  Đ.1" }
        \line { \small "-Cn B /26TN: câu 1, 2, 5, 6, 7 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t5 l /26TN: câu 1, 2, 3, 4 + Đ.2" }
        \line { \small "-t2 /1MC: câu 1, 2, 3, 4 + Đ.1" }
        \line { \small "-Cn B /3MC: câu 1, 2, 3, 4 + Đ.4" }
        \line { \small "-Vọng PS: câu 1, 2, 3, 4 + Đ.4" }
        \line { \small "-T.Tiến sĩ: câu 1, 2, 3, 4 + Đ.1 hoặc Đ.2" }
        \line { \small "-Nt trao kinh Tin kính: như trên" }
        \line { \small "-khi tĩnh tâm: câu 1, 2, 3, 4 + Đ.4" }
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
    \override Lyrics.LyricSpace.minimum-distance = #1.5
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
    \override Lyrics.LyricSpace.minimum-distance = #0.6
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    ragged-last = ##f
  }
}

