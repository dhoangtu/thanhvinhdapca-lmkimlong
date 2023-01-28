% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 97"
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
  \partial 8 c8 |
  a4 \tuplet 3/2 { f8 bf a } |
  g4 \tuplet 3/2 { e8 f g } |
  c,4 r8 c |
  a'4. f16 f |
  bf4 \tuplet 3/2 { c8 a f } |
  g4 r8 c, |
  g'4. f16 g |
  a4 \tuplet 3/2 { g8 a bf } |
  c4 r8 c |
  d4. bf16 d |
  c4 \tuplet 3/2 { d8 bf g } |
  f4 r8 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a8 |
  g (a) d, (f) |
  g2 |
  <<
    {
      bf8 g4 c8
    }
    {
      g8 e4 e8
    }
  >>
  f4 r8 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a8 |
  d, f a g
  <<
    {
      c4 a8 (g) |
      c,2 ~ |
      c8 g' e f |
      f2 ~ |
      f4 r8 \bar "|."
    }
    {
      e4 c8 (bf) |
      a2 ~ |
      a8 bf c bf |
      a2 ~ |
      a4 r8
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      c8 |
      a4 bf8 a |
      g f g (a) |
      bf2 |
      bf8 bf d g, |
      g8. g16
    }
    {
      a8 |
      f4 g8 f |
      e d e (f) |
      g2 |
      g8 g f f |
      e8. d16
    }
  >>
  e16 (d) c8 |
  <f a,>4 r8 \bar "|."
}

nhacPhanNam = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 f8 |
  g (a) g (f) |
  c
  <<
    {
      e8 f (g) |
      a4 bf8 d |
      g,2
    }
    {
      c,8 d (e) |
      f4 g8 f |
      e2
    }
  >>
  c8
  <<
    {
      e8 g g |
      f4 r8 \bar "|."
    }
    {
      c8 bf bf |
      a4 r8
    }
  >>
}

nhacPhanSau = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8
  <<
    {
      a8 |
      bf4. g8 |
      c c d, f |
      g2 ~
    }
    {
      f8 |
      g4. f8 |
      e d bf d |
      c2
    }
  >>
  g'8 e16 (d)
  <<
    {
      c8 f |
      f2 ~ |
      f4 r8 \bar "|."
    }
    {
      bf,8 bf |
      a2 ~ |
      a4 r8
    }
  >>
}

nhacPhanBay = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 c8 |
  <<
    {
      a'4 f8 a |
      bf4. g8 |
      c4 bf8 g |
      g4.
    }
    {
      f4 d8 f |
      g4. f8 |
      e4 d8 d |
      c4.
    }
  >>
  c8 |
  <<
    {
      a'8 g4 e8 |
      f4 r8 \bar "|."
    }
    {
      f8 bf,4 c8 |
      a4 r8
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hát lên một khúc tân ca ngợi khen Chúa Trời,
      vì Chúa đà tạo tác biết bao kỳ công.
      Nhờ tay thực uy dũng Ngài đã vinh thắng,
      vinh thắng nhờ cánh tay thánh thiện của Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa nay dọi chiếu trên ta hồng ân cứu độ,
      mạc khải cùng vạn quốc đức công bình đây.
      Tình thương, lòng trung tín rầy Ngài lại nhớ,
      ban xuống nhà Ích -- diên chính dân riêng Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Khắp nơi toàn cõi dương gian rầy đã ngắm nhìn,
      nhìn Chúa dùng quyền phép cứu độ trần gian.
      Nào mau ngợi khen Chúa, địa cầu muôn nơi,
      vui sướng đàn hát lên hỉ hoan reo hò.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Hãy mau đàn hát lên đi, mừng vui kính Ngài,
      hòa khúc hạc cầm trổi, cất cao giọng ca.
      Kèn vang điệu réo rắt hòa chen tiếng ốc, dâng Chúa,
      Vị quốc vương để tung hô Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Biển khơi gào thét vang xa cùng bao hải vật,
      Hoàn vũ cùng hợp tiếng với nhân trần đi.
      Hò reo và vui sướng, hỡi muôn đỉnh núi,
      Sông nước hãy vỗ tay trước tôn nhan Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa nay ngự đến vinh quang điều khiển vũ hoàn.
      Ngài đến và Ngài sẽ xét soi trần gian.
      Ngàn dân Ngài minh xét thực là công chính,
      theo sát đường thẳng ngay xét xử địa cầu.
    }
  >>
}

loiPhanHai = \lyricmode {
  Chúa đã biểu dương ơn Ngài cứu độ.
}

loiPhanBa = \lyricmode {
  Chúa mạc khải đức công chính của Ngài trước mặt chư dân.
}

loiPhanBon = \lyricmode {
  Hát lên khúc tân ca mừng Thiên Chúa,
  vì Ngài đã thực hiện biết bao kỳ công.
}

loiPhanNam = \lyricmode {
  Toàn cõi đất này đã xem thấy ơn cứu độ của Thiên Chúa chúng ta.
}

loiPhanSau = \lyricmode {
  Đây Chúa ngự đến xét xử trần gian theo đường công minh.
}

loiPhanBay = \lyricmode {
  Lạy Chúa là Thiên Chúa toàn năng,
  sự nghiệp Ngài thực lớn lao kỳ diệu.
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
        \line { \small "-lễ ngày GS: câu 1, 2, 3, 4 + Đ.4" }
        \line { \small "-ngày 2/1: câu 1, 2, 3 + Đ.4" }
        \line { \small "-ngày 3/1: câu 1, 3, 4 + Đ.4" }
        \line { \small "-ngày 4/1: câu 1, 5, 6 + Đ.4" }
        \line { \small "-t2 l /3TN: câu 1, 2, 3, 4 + Đ.3" }
        \line { \small "-t3 c /8TN: câu 1, 2, 3 + Đ.1" }
        \line { \small "-t2 l /11TN: câu 1, 2, 3 + Đ.1" }
        \line { \small "-t7 l /21TN: câu 2, 3, 4 + Đ.5" }
        \line { \small "-t5 l /22TN: câu 2, 3, 4 + Đ.1" }
        \line { \small "-Cn C /28TN: câu 1, 2, 3 + Đ.2" }
        \line { \small "-t2 l /28TN: câu 1, 2, 3 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t5 c /28TN: câu 1, 2, 3, 4 + Đ.1" }
        \line { \small "-t6 l /31TN: câu 1, 2, 3 + Đ.1" }
        \line { \small "-Cn C /33TN: câu 4, 5, 6 + Đ.5" }
        \line { \small "-t4 c /34TN: câu 1, 2, 5, 6 + Đ.6" }
        \line { \small "-t7 /4PS: câu 1, 2, 3 + Đ.4" }
        \line { \small "-Cn B /6PS: câu 1, 2, 3 + Đ.2" }
        \line { \small "-t5 /6PS: câu 1, 2, 3 + Đ.2" }
        \line { \small "-T.Barnabê: câu 1, 2, 3 + Đ.2" }
        \line { \small "-Mẹ Vô Nhiễm: câu 1, 2, 3 + Đ.3" }
        \line { \small "-Cung hiến TĐ Phêrô & Phaolô:" }
        \line { \small "    câu 1, 2, 3, 4 + Đ.2" }
        \line { \small "-loan báo Tin Mừng: câu 1, 2, 3, 4 + Đ.2" }
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
