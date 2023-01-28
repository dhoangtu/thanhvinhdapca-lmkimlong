% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 101"
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
  \partial 8 f8 |
  f e f g |
  c,4. c8 |
  a'4 r8 a |
  a bf4 a8 |
  g8. e16 c'8 c |
  f,2 |
  d'8. bf16 g8 bf |
  c4. a8
  \once \stemUp
  bf8
  <<
    {
      \voiceOne
      bf
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #1
      \parenthesize
      g
    }
  >>
  g8 (f) |
  e2 |
  d8. c16 f8 g |
  a4. a16 bf |
  g8 d g16 g a8 |
  f4 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  f4. f8 |
  <<
    {
      g4. bf8 |
      bf g c c
    }
    {
      e,4. g8 |
      g f e e
    }
  >>
  f4 r8 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key f \major
  \time 2/4
  <<
    {
      c4. c8 |
      bf g g a |
      a4 f8 a |
      d,2 |
      c8 g'4 f8 |
      f4 r8 \bar "|."
    }
    {
      a4. a8 |
      g e e f |
      f4 d8 c |
      bf2 |
      a8 bf4 bf8 |
      a4 r8
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key f \major
  \time 2/4
  <<
    {
      a4. bf8 |
      g e f g8
    }
    {
      f4. g8 |
      e c d b!8
    }
  >>
  c4. c8 |
  <<
    {
      a'4 r8 bf16 a |
      g8 g16 e c'8 c
    }
    {
      f,4 r8 g16 f |
      e8 d16 c e8 e
    }
  >>
  f4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Xin nghe lời con khấn cầu, lạy Chúa,
      mong sao tiếng con kêu được thấu tới Ngài.
      Lúc con gặp gian truân, xin Chúa chớ ẩn mặt.
      Trong ngày con kêu cứu xin lắng nghe mà mau mau đáp lời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Muôn dân sẽ tôn kính Ngài, lạy Chúa,
      vinh quang Chúa, vương công trần thế quý trọng.
      Chúa xây lại Si -- on, soi chiếu ánh huy hoàng.
      Bao người bị uy hiếp, nay Chúa thương chẳng khinh khi tiếng họ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Uy công này ghi chép lại hậu thế,
      cho dân chúng mai sau mừng kính Chúa Trời.
      Chúa trên trời cao xa đưa mắt ngó cõi trần,
      nghe tù nhân rên xiết, xin cứu nguy kẻ lâm nguy tử hình.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Muôn dân Ngài luôn thống trị, lạy Chúa,
      Tôn danh Chúa thiên thu còn nhắc nhớ hoài.
      Chúa chỗi dậy uy linh thương xót
      \markup { \underline "Si" } "- on" này.
      Đây kỳ hạn đã tới, tay Chúa ban đầy dư muôn phúc lộc.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Cho miêu duệ tôi tớ này lạc phúc,
      Mong sao trước Thiên Nhan dòng dõi vĩnh tồn.
      Khắp nơi ở Si -- on cho tới
      \markup { \underline "Gia" } "- liêm"
      này rao truyền ngợi khen Chúa,
      muôn sắc dân tập trung tôn kính Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Con hao kiệt thân sức rồi, lạy Chúa,
      sao nay tháng năm con Ngài rút ngắn lại?
      Chúa vĩnh tồn thiên thu,
      Ôi Đấng \markup { \underline "con" } tôn thờ,
      Xin Ngài đừng vội vã đem cắt ngang mạng con khi nửa đời.
    }
  >>
}

loiPhanHai = \lyricmode {
  Từ trời xanh, Chúa đã nhìn xuống cõi trần.
}

loiPhanBa = \lyricmode {
  Chúa sẽ xây dựng lại Si -- on và xuất hiện rực rỡ vinh quang.
}

loiPhanBon = \lyricmode {
  Xin lắng nghe lời con khấn cầu, lạy Chúa,
  Tiếng con kêu mong được thấu tới Ngài.
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
        \line { \small "-t5 l /6TN: câu 2, 3, 5 + Đ.1" }
        \line { \small "-t5 c /15TN: câu 4, 2, 3 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t3 c 18TN: câu 2, 3, 5 + Đ.2" }
        \line { \small "-t2 l /26TN: câu 2, 3, 5 + Đ.2" }
        \line { \small "-t3 /5MC: câu 1, 4, 2, 3 + Đ.3" }
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
