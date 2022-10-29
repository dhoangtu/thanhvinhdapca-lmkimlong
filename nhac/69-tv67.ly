% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 67"
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
  \partial 8 d16 d |
  b4 \tuplet 3/2 { g8 g b } |
  d,4. d16 [
  <<
    {
      \voiceOne
      b']
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #-1
      \tweak font-size #-2
      \parenthesize
      d,16
    }
  >>
  \oneVoice
  b'4 \tuplet 3/2 { g8 c b } |
  a4 r8 d, |
  g fs g (a) |
  b8. c16
  <<
    {
      \voiceOne
      b8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #-2
      \tweak font-size #-2
      \parenthesize
      a
    }
  >>
  \oneVoice
  a |
  d d b16 (a) d8 |
  g,2 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key g \major
  \time 2/4
  a8 g e (g) |
  <<
    {
      a4. c8 |
      c a d4
    }
    {
      fs,4. e8 |
      e e fs4
    }
  >>
  g4 r8 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key g \major
  \time 2/4
  <<
    {
      b8 d c (b) |
      a4. d,8 |
      a' b b (a) |
      g4 r8 \bar "|."
    }
    {
      g8 a a (g) |
      d4. d8 |
      cs e d (c!) |
      b4 r8
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key g \major
  \time 2/4
  g4.
  <<
    {
      a8 |
      b4 c8 b |
      a4. d8 |
      d d, b' (a) |
      g2 ~ |
      g4 r8 \bar "|."
    }
    {
      fs8 |
      g4 a8 g |
      fs4. e8 |
      d b d (c) |
      b2 ~ |
      b4 r8
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Chúa đứng lên, địch thù tán loạn,
      kẻ ghét Chúa chạy trốn thánh nhan.
      Còn ai người công chính múa
      \markup { \underline "nhảy" } mừng rỡ trước nhan thánh Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa đứng lên địch thù tán loạn,
      kẻ ghét Chúa chạy trốn thánh nhan,
      cuộn đi tựa hơi khói, chảy ra tựa sáp lúc gặp lửa hồng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Hãy sướng vui, nài người chính trực,
      cùng múa hát ở trước thánh nhan,
      Đàn ca mừng Thiên Chúa,
      hãy \markup { \underline "dọn" } đường Đấng cỡi mây xuất hiện.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Đấng đỡ nâng cô nhi, góa phụ,
      là chính Chúa ngự giữa thánh cung,
      Tù nhân Ngài giải thoát,
      kẻ đơn độc Chúa sẽ ban cửa nhà.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Hãy trút mưa ân thiêng phúc lộc,
      sản nghiệp Chúa được tiếp sức cho,
      Đàn chiên được nâng đỡ, bởi \markup { \underline "Ngài" }
      từ ái với kẻ khó nghèo.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Chúa cứu ta và hằng đỡ đần,
      ngày ngày hãy mừng chúc Chúa liên.
      Đường xa khỏi thần chết chính \markup { \underline "là" } ở Chúa,
      Đấng ta kính thờ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Chúa biểu dương quyền lực của Ngài,
      nguyện củng cố việc đã khở công.
      Này bao vị vua chúa tiến \markup { \underline "về" }
      đền thánh kính dâng lễ vật.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Các quốc vương cùng đàn hát nào,
      mừng kính Chúa ngự chốn thẳm cao.
      Này đây Ngài lên tiếng,
      tiếng \markup { \underline "thật" } quyền phép.
      hãy tôn kính Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Cõi nước mây, Ngài tỏ dũng lực,
      dọi ánh sáng vào Is -- ra -- el.
      Tặng dân Ngài uy phép,
      bởi \markup { \underline "Ngài" } là Đấng chí tôn chí đại.
    }
  >>
}

loiPhanHai = \lyricmode {
  Vương quốc trần gian hãy hát mừng Chúa Trời.
}

loiPhanBa = \lyricmode {
  Thiên Chúa chúng ta là Thiên Chúa cứu độ.
}

loiPhanBon = \lyricmode {
  Lạy Thiên Chúa, Chúa nhân hậu đối với kẻ khó nghèo.
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
        \line { \small "-Cn C /22TN: câu 3, 4, 5 + Đ.3" }
        \line { \small "-t2 l /30TN: câu 1, 4, 6 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t2 /7PS: câu 2, 3, 4 + Đ.1" }
        \line { \small "-t3 /7PS: câu 5, 6 + Đ.1" }
        \line { \small "-t4 /7PS: câu 7, 8, 9 + Đ.1" }
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
