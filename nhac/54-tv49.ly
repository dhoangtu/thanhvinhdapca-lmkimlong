% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 49"
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
  \partial 8 g8 |
  g4 \tuplet 3/2 { c,8 f f } |
  e8. e16 d8 g |
  a4 r8 g16 c |
  c8 b b8. a16 |
  a8 a a d |
  g,4 r8 e16 a |
  a4 \tuplet 3/2 { f8 a d, } |
  d8. d16 e (d) c8 |
  g'4. g8 |
  f4. e8 |
  a4 \tuplet 3/2 { d,8 f g } |
  c,2 \bar "||"
  c4 r8 \bar "" \break
  f16 e |
  d4 \tuplet 3/2 { f8 e e } |
  a4 r8 a16 a |
  g4 \tuplet 3/2 { d'8 d b } |
  c2 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key c \major
  \time 2/4
  <<
    {
      g8. g16 e8 g |
      a4. g16 g |
      d8 f g g |
      c,4 r8 \bar "|."
    }
    {
      e8. e16 c8 e |
      f4. e16 c |
      b8 d c b |
      c4 r8
    }
  >>
}

nhacPhanBa = \relative c'' {
  \key c \major
  \time 2/4
  <<
    {
      g8. g16 e8 e |
      f4 d8 g |
      c,2 ~ |
      c4 r8 \bar "|."
    }
    {
      e8. e16 c8 c |
      d4 b8 b |
      c2 ~ |
      c4 r8
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key c \major
  \time 2/4
  <<
    {
      g8. g16 e8 e |
      a4. a8 |
      d, f g g |
      c,4 r8 \bar "|."
    }
    {
      e8. e16 c8 c |
      f4. c8 |
      b d c b |
      c4 r8
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Đức Chúa, Thượng Đế chí tôn nay Ngài lên tiếng,
      Từ khắp cõi đông tây Ngài triệu tập cả vũ hoàn.
      Từ Si -- on cảnh sắc tuyệt vời Thiên Chúa hiển linh,
      Chúa ta ngự đến, Ngài không nín _ lặng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Đức Chúa, Thượng Đế chí tôn nay Ngài lên tiếng,
      Từ khắp cõi đông tây Ngài triệu tập cả vũ hoàn.
      Này Ta đây chẳng trách phiền gì hy lễ của ngươi,
      lễ thiêu hằng thấy ở ngay trước mặt.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Chúa phán: Triệu hết tới đây bao người trung tín,
      từng kết ước minh giao, từng thề nguyền bằng lễ vật.
      Trời cao nay truyền bá về sự công chính của Chúa.
      Bởi đây Ngài sẽ ngự ra xét xử.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Dẫn chứng để tố cáo ngươi, dân tộc Ta hỡi,
      dòng giống Is -- ra -- el nghe lời dạy của Chúa mình:
      Này Ta đây chẳng trách phiền gì hy lễ của ngươi,
      lễ thiêu hằng thấy ở ngay trước mặt.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Đức Chúa chẳng trách cứ chi ngươi về hy lễ,
      vì lễ tế thiêu sinh hằng ngào ngạt ở trước mặt.
      Vì Ta đây chẳng lẽ lại cần chiên béo của ngươi,
      lẽ đâu lại hám bò người hiến tặng?
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Dã thú rừng rú thẳm sâu luôn thuộc Ta đó,
      cùng với biết bao nhiêu là động vật miền núi đồi,
      Và chim muông ở khắp bầu trời Ta biết thực rõ,
      thú nơi đồng áng thuộc Ta hết mà.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Dẫu đói nào có ích chi Ta để ngươi biết,
      vì khắp cõi dương gian vạn vật thuộc quyền Chúa này,
      Đồ Ta ăn chẳng lẽ lại là thịt lũ bò tơ,
      máu chiên chẳng lẽ đồ Ta uống nào.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Hãy tới và tiến lễ lên cảm tạ Thiên Chúa,
      cùng Đấng Tối Cao đây hãy làm trọn điều ước thề.
      Ngày khốn khó chạy đến nguyện cầu, Ta sẽ giải nguy.
      Bởi ngươi rồi sẽ làm Ta chói rạng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Vẫn biết: mọi huấn giới Ta người thường hay nhắc,
      lời thánh ước bô bô lặp lại hoài ở cửa miệng,
      Mà sao ngươi lại ghét bỏ điều Ta sửa dạy ngươi.
      vứt sau chẳng ngó lời Ta phán truyền.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Vẫn thói ngồi rỗi nói lia bôi nhọ thân hữu,
      và bới xấu bôi nhơ cả người ruột thịt nghĩa tình,
      Lại dám nghĩ Ta đây đồng lòng, nên mãi làm thinh.
      Đây Ta khiển trách, vạch cho rõ tội.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      Gắng sức mà thấu suốt đi, ai từng quên Chúa,
      kẻo lúc Chúa ra tay thì người nào mà cứu được.
      Rạng danh Ta khi có người nào dâng lễ tạ ơn.
      Ai ở lành thánh được Ta cứu độ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "12."
      \override Lyrics.LyricText.font-shape = #'italic
      Hãy tới mà tiến lễ lên cảm tạ Thiên Chúa,
      cùng Đấng Tối Cao đây hãy làm trọn điều ước thề.
      Rạng danh ta khi có người nào dâng lễ tạ ơn.
      Ai ở lành thánh được Ta cứu độ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "13."
      Đến thế mà dám nghi Ta như là ngươi chứ,
      chẳng lẽ nín thinh ư? Ta rầy vạch tội rõ ràng.
      Rạng danh Ta khi có người nào dâng lễ tạ ơn.
      Ai ở lành thánh được Ta cứu độ.
    }
  >>
  \stanzaReminderOff
  \set stanza = "1"
  Trước nhan Ngài lửa bừng bừng cháy,
  bao quanh Ngài vũ bão cuồng phong.
}

loiPhanHai = \lyricmode {
  Ai theo đường ngay chính, Ta cho hưởng ơn Chúa cứu độ.
}

loiPhanBa = \lyricmode {
  Hãy tiến dâng Thiên Chúa lời tán tụng.
}

loiPhanBon = \lyricmode {
  Hãy gắng mà hiểu rõ, hỡi kẻ quên lãng Chúa Trời.
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
        \line { \small "-t2 c /2TN: câu 5, 9, 13 + Đ.1" }
        \line { \small "-t2 l /6TN: câu 2, 9, 10 + Đ.1" }
        \line { \small "-t3 l /8TN: câu 3, 4, 12 + Đ.1" }
        \line { \small "-Cn A /10TN: câu 2, 7, 8 + Đ.1" }
        \line { \small "-t2 c /13TN: câu 9, 10, 11 + Đ.3" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t4 c /13TN: câu 4, 6, 7, 9 + Đ.1" }
        \line { \small "-t2 c /15TN: câu 5, 9, 13 + Đ.1" }
        \line { \small "-t2 c /16TN: câu 5, 9, 13 + Đ.1" }
        \line { \small "-t7 l /16TN: câu 1, 3, 8 + Đ.2" }
        \line { \small "-t5 l /33TN: câu 1, 3, 8 + Đ.2" }
        \line { \small "-t3 /2MC: câu 5, 9, 13 + Đ.1" }
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
