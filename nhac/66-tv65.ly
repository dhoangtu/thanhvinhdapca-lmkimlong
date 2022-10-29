% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 65"
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
  \key g \major
  \time 2/4
  \partial 8 d16 d |
  b'4 \tuplet 3/2 { g8 a b } |
  c4. c16 e |d8. b16 \tuplet 3/2 { d8 c b } |
  a4 \tuplet 3/2 { g8 fs g } |
  e8. e16 \tuplet 3/2 { g8 g a } |
  d,4 r8 d16 d |
  b'8. a16 \tuplet 3/2 { d8 d fs, } |
  g4 \bar "||"
}

nhacPhanHai = \relative c' {
  \key g \major
  \time 2/4
  \partial 4 d8 d |
  <<
    {
      b'4. c8 |
      a a4 d8
    }
    {
      g,4. a8 |
      g fs4 fs8
    }
  >>
  g2 ~ |
  g4 r8 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key g \major
  \time 2/4
  \partial 4 g8 a16 (g) |
  d4.
  <<
    {
      a'8 |
      b2 |
      c8 a a a |
      d4. fs,8 |
      g4 r8 \bar "|."
    }
    {
      d8 |
      g2 |
      a8 g fs e |
      fs4. d8 |
      b4 r8
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Toàn cầu hỡi, nào tung hô Chúa,
      đàn hát lên mừng Thánh Danh rạng ngời.
      Dâng lời tán tụng và thân thưa Chúa rằng:
      Sự nghiệp Chúa thật đáng khiếp sợ thay.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Toàn cầu hãy phục suy tôn kính,
      đàn hát lên mừng Thánh Danh Chúa Trời.
      Mau hãy đến nhìn từng uy công Chúa làm,
      việc khủng khiếp Ngài đối với phàm nhân.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Ngài từng khiến đại dương trơ đất,
      và dắt dân dạo bước qua sống ngòi.
      Ta mừng rỡ vì ngàn uy công Chúa làm,
      Ngài nhìn rõ và thống lãnh vạn dân.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Nào cùng đến nhìn uy công Chúa,
      việc khiếp kinh Ngài đối với nhân trần.
      Mau hãy chúc tụng, nào muôn dân cõi trần,
      cùng rập tiếng mà hát xướng ngợi khen.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Này vạn quốc, nào ca khen Chúa,
      cùng xướng lên lời tán dương dâng Ngài.
      Sinh mạng mỗi người được luôn luôn bảo toàn,
      và gìn giữu khỏi lỡ bước hụt chân.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Nào cùng đến nhìn uy công Chúa,
      việc khiếp kinh Ngài đối với nhân trần.
      Tay Ngài đã làm đại dương ra đất liền,
      và dìu chúng cùng ráo bước vượt sông.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Nào cùng đến mà nghe tôi nói,
      thảy những ai hằng kính tôn Chúa Trời.
      Bao việc Chúa làm, nài tôi xin tán tụng,
      và miệng lưỡi cầu khấn tới Ngài liên.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Lòng thành kính nguyện dâng lên Chúa,
      lời tán dương mừng Chúa tôi tôn thờ.
      Tôi câu khấn Ngài, Ngài không chê bác lời,
      và lại cũng chẳng dứt nghĩa tình đâu.
    }
  >>
}

loiPhanHai = \lyricmode {
  Toàn cầu hỡi, hãy tung hô Chúa Trời.
}

loiPhanBa = \lyricmode {
  Xin chúc tụng Thiên Chúa, Đấng bảo toàn mạng sống của ta.
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
        \line { \small "-Cn C /14TN: câu 1, 2, 3 + Đ.1" }
        \line { \small "-t4 l /19TN: câu 1, 4, 7 + Đ.2" }
        \line { \small "-t4 /3PS: câu 1, 2, 3 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-t5 /3PS: câu 5, 7, 8 + Đ.1" }
        \line { \small "-Cn A /6PS: câu 1, 2, 3, 8 + Đ.1" }
        \line { \small "-Rửa tội: câu 1, 3, 5, 7 + Đ.1" }
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
