% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 110"
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
  \key c \major
  \time 2/4
  \partial 4. e8 e f |
  d4 e8 c |
  g'2 ~ |
  g8 c b
  <<
    {
      \voiceOne
      \once \stemDown d
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #2
      \tweak font-size #-2
      \parenthesize
      b
    }
  >>
  \oneVoice
  c8. g16 c8 e, |
  d2 ~ |
  d4 d8 d |
  a'8 c a16 (g) f8 |
  g4 d8 f |
  g8. g16 e8 d |
  c4 r8 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8
  <<
    {
      g8 |
      e4 a8 a |
      a4. f8 |
      g d
    }
    {
      e8 |
      c4 f8 f |
      f4. d8 |
      c c
    }
  >>
  <<
    {
      \voiceOne
      f8 (e16 d)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      b4
    }
  >>
  \oneVoice
  c2 ~ |
  c8
  \bar "|."
}

nhacPhanBa = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8
  <<
    {
      g8 |
      e4 f8 g |
      d4. d8 |
      d d
    }
    {
      e8 |
      c4 d8 c |
      b4. b8 |
      b b
    }
  >>
  <<
    {
      \voiceOne
      f'8 (e16 d)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      b4
    }
  >>
  \oneVoice
  c2 ~ |
  c8
  \bar "|."
}

nhacPhanBon = \relative c' {
  \key c \major
  \time 2/4
  \partial 8 c8 |
  <<
    {
      g'4. g8 |
      e f g d |
      d4. d8 |
      f f
    }
    {
      b,4. b8 |
      c d c c |
      b4. b8 |
      a a
    }
  >>
  <<
    {
      \voiceOne
      d8 e16 (d)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      b8 b
    }
  >>
  \oneVoice
  c2 ~ |
  c8
  \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Tôi xin hết lòng cảm tạ Chúa
      trong hội chính nhân và giữa cộng đoàn.
      Sự nghiệp Chúa lớn lao dường bao,
      người mộ mến gắng suy cho tường.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Uy công Chúa làm bao hiển hách,
      Đức công \markup { \underline "minh" } Chúa bền vững muôn đời.
      Ngài truyền nhớ hết mọi kỳ công.
      Thực Thiên Chúa mến thương nhân từ.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Uy công Chúa truyền hãy tưởng nhớ
      Bởi vì Chúa luôn từ ái nhân hậu.
      Kẻ sùng kính, Chúa ban của ăn,
      Và Giao ước Chúa ghi muôn đời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Công minh chính trực, vĩ nghiệp Chúa,
      Quy luật Chúa ban đều đáng tin cậy,
      còn bền vững tới muôn ngàn năm,
      vì căn cứ lẽ ngay chân thật.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Minh giao Chúa lập luôn bền vững.
      Ơn Giải thoát dân, Ngài đã đem lại,
      Thật rạng rỡ thánh thiêng dường bao,
      và khả úy mãi tôn danh Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Minh giao Chúa lập luôn bền vững,
      Ơn Giải thoát dân, Ngài đã đem lại.
      Thật khả úy thánh danh thần thiêng,
      được cung chúc đến muôn muôn đời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Khôn ngoan chính là tôn sợ Chúa.
      Ai hằng dõi theo là rất tinh tường,
      Còn bền vững đến muôn ngàn năm
      lời ca hát tán dương danh Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Minh giao đã lập Chúa hằng nhớ,
      Ban thực phẩm cho kẻ kính sợ Ngài,
      Được nhìn ngắm biết bao kỳ công,
      của chư dân Chúa đem trao tặng.
    }
  >>
}

loiPhanHai = \lyricmode {
  Muôn đời Chúa nhớ mãi Giao ước Ngài đã lập.
}

loiPhanBa = \lyricmode {
  Công việc tay Chúa làm quả thực là vĩ đại.
}

loiPhanBon = \lyricmode {
  Lạy Chúa, công trình tay Chúa thực hiện đều công minh và chân thực.
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
        \line { \small "-t3 l /2TN: câu 1, 3, 6 + Đ.1" }
        \line { \small "-t2 c /8TN: câu 1, 3, 6 + Đ.1" }
        \line { \small "-t5 l /1TN: câu 1, 2, 4 + Đ.3" }
        \line { \small "-t4 l /24TN: câu 1, 2, 8 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-t5 l /24TN: câu 4, 5, 7 + Đ.2" }
        \line { \small "-t2 c /27TN: câu 1, 4, 6 + Đ.1" }
        \line { \small "-t6 c /27TN: câu 1, 2, 8 + Đ.1" }
        \line { \small "-t6 c /30TN: câu 1, 2, 8 + Đ.2" }
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
    \override Lyrics.LyricSpace.minimum-distance = #2
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \override LyricHyphen.minimum-distance = #2.0
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
    \override Lyrics.LyricSpace.minimum-distance = #2
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \override LyricHyphen.minimum-distance = #2.0
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
    \override Lyrics.LyricSpace.minimum-distance = #2
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \override LyricHyphen.minimum-distance = #2.0
    ragged-last = ##f
  }
}
