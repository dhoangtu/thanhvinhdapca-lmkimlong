% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 83"
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
  \partial 8 e8 |
  f8. a16 f8 e |
  d4. d16
  <<
    {
      \voiceOne
      c16
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #-1.6
      \tweak font-size #-2
      \parenthesize
      d16
    }
  >>
  \oneVoice
  c8 c f e16 (f) |
  \grace { g16 (a } g4) r8 bf |
  g8. g16 bf8 d |
  c4. a16 a |
  g8 e a16 (g) e8 |
  f2 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  f4. c8 |
  <<
    {
      f4. bf16 a |
      g8 g bf c
    }
    {
      f,4. g16 f |
      e8 e d e
    }
  >>
  f4 r8 \bar "|."
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  f8. a16 d,8 f |
  g4. g16 f |
  <<
    {
      bf8 g c e, |
      f4 r8 \bar "|."
    }
    {
      d8 f e c |
      a4 r8
    }
  >>
}

nhacPhanBon = \relative c' {
  \key f \major
  \time 2/4
  f4 c8 c |
  d4.
  <<
    {
      f16 (g) |
      a8 g
    }
    {
      d16 (c) |
      f8 f
    }
  >>
  <<
    {
      \voiceOne
      c'8 a16 (g)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      e8 e
    }
  >>
  \oneVoice
  f4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hồn con khát khao mỏi mòn mong được về hành lang nhà Chúa,
      Tâm thần và thể xác con hân hoan vọng tới Chúa trường sinh.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Lạy Thiên Chúa con tôn thờ,
      chim sẻ còn tìm nơi ẩn trú,
      chim nhạn làm tổ náu thân ngay bên bàn thánh Chúa càn khôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Thật vinh phúc ai nương nhờ nơi đền thờ,
      và ca tụng Chúa.
      Kẻ Ngài phù trợ, phúc thay.
      Nay xin Ngài đoái nghe lời con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Thật vinh phúc ai nương nhờ nơi đền thờ,
      và ca tụng Chúa,
      Ôi Ngài mộc khiên chở che,
      xin xem Người Chúa xức dầu cho.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Được ở thánh cung một ngày
      hơn ngàn ngày ở nơi nào khác.
      Cổng đền Ngài ở vẫn hơn trong doanh trại những quân tàn hung.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Ngài như thái dương, khiên mộc,
      ban \markup { \underline "ân" } lộc và cho hiển sáng.
      Bao người trọn hảo Chúa thương,
      không chi từ chối ban hồng ân.
    }
  >>
}

loiPhanHai = \lyricmode {
  Ôi lạy Chúa, phúc thay người ở trong thánh điện.
}

loiPhanBa = \lyricmode {
  Lạy Chúa Tể càn khôn,
  cung điện Chúa khả ái dường bao.
}

loiPhanBon = \lyricmode {
  Đây là Nhà Tạm Thiên Chúa ở với nhân loại.
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
        \line { \small "-t3 c /5TN: câu 1, 2, 4, 5 + Đ.2" }
        \line { \small "-t7 c /16TN: câ 1, 2, 3, 6 + Đ.2" }
        \line { \small "-t5 l /17TN: câu 1, 2, 3, 6 + Đ.2" }
        \line { \small "-t6 c /22TN: câu 1, 2, 3, 6 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t6 c /34TN: câu 1, 2, 3 + Đ.3" }
        \line { \small "-cung hiến T.Đường: câu 1, 2, 3, 5 + Đ.2 hoặc Đ.3" }
        \line { \small "-Truyền chức - Khấn dòng - Cầu ơn thiên triệu:" }
        \line { \small "          câu 1, 2, 3, 5 + Đ.1" }
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
