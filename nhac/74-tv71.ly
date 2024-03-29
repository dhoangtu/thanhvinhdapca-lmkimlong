% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 71"
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
  \partial 4. f4 e8 |
  a4. a16 a |
  f8 bf a g |
  g4. g16 g |
  a8 g g d |
  \grace { d16 ( } e2) ~ |
  e8 f4
  <<
    {
      \voiceOne
      g8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #1.5
      \tweak font-size #-2
      \parenthesize
      f
    }
  >>
  \oneVoice
  g4. g16 g |
  a8 a f e |
  d4. d16 c |
  c8 d g e |
  f2 ~ |
  f4 r \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  c8 c c (d) |
  f8. e16
  <<
    {
      f8 g |
      a2 |
      g8 g g bf |
      c4
    }
    {
      d,8 e |
      f2 |
      e8 e e d |
      e4
    }
  >>
  <<
    {
      \voiceOne
      g16 (a) g8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      e8 e
    }
  >>
  \oneVoice
  f2 ~ |
  f8 \bar "|."
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  \partial 4 c4 |
  <<
    {
      a'4. a8 |
      a4 bf8 a |
      g8. g16 g8 c
    }
    {
      f,4. f8 |
      f4 g8 f |
      e8. e16 e8 e
    }
  >>
  f2 ~ |
  f8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Tâu Thượng Đế, xin ban quyền bính cho Tân vương,
      trao công lý trong tay hoàng tử.
      Để Tân vương theo công lý xét xử dân Ngài,
      bênh quyền lợi kẻ khó nghèo luôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Nay đồi núi rước thái bình đến cho muôn dân
      đem công lý cho bao dòng họ.
      Người ra tay luôn bênh đỡ những kẻ cơ cùng,
      ai nghèo hèn Người cứu độ cho.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Vương triều sẽ luôn đua nở thám hoa công minh,
      thiên thu mãi an ninh thịnh trị.
      Người \markup { \underline "quản" } cai
      qua sống Cái đến tận địa cầu,
      qua biển này và tới biển kia.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Bao hoàng đế đến mãi từ Thác -- si, Xơ -- va,
      hay nơi thẳm xa bao quần đảo,
      Cùng vương công chen nhau bước tới tự Ả -- rập,
      đem phẩm vật triều cống phục suy.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Ai nghèo khó khấn vái Ngài sẽ luôn thương nghe,
      ra tay cứu con dân cùng khổ.
      Chạnh \markup { \underline "lòng" } thương
      ai nguy khốn, bé nhỏ, đơn hèn,
      Dân bần cùng Người tế độ cho.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Thiên hạ sẽ tiến đến cầu khấn cho Tân vương,
      xin vinh chúc Tân vương vạn thuở.
      Người thương dân ra tay cứu thoát khỏi bạo tàn,
      Coi trọng từng giọt máu họ luôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Danh Người sẽ chói sáng cùng thái dương lan xa,
      qua muôn kiếp muôn năm trường cửu.
      Nhờ Tôn Danh, muôn dân cõi thế được chúc lành,
      thiện hạ cùng cầu phúc Người luôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Xin mừng chúc Đức Cháu là Chúa Is -- ra -- en,
      Uy công Chúa trăm muôn kỳ diệu,
      Nguyện Tôn Danh luôn cao sáng đến mãi muôn đời,
      Vinh hiển Ngài dọi khắp trần gian.
    }
  >>
}

loiPhanHai = \lyricmode {
  Triều đại Người đua nở hoa công lý
  và hòa bình viên mãn đến muôn đời.
}

loiPhanBa = \lyricmode {
  Lạy Chúa, muôn dân khắp địa cầu cùng thờ kính Ngài.
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
        \line { \small "-t3 /1MV: câu 1, 3, 5, 7 + Đ.1" }
        \line { \small "-Cn A /2MV: câu 1, 2, 5, 7 + Đ.1" }
        \line { \small "-ngày 17/12: câu 1, 5, 8 + Đ.1" }
        \line { \small "-ngày 18/12: câu 1, 5, 8 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small "-lễ Hiển linh: câu 1, 3, 5, 7 + Đ.2" }
        \line { \small "-ngày 8/1: câu 1, 2, 3 + Đ.2" }
        \line { \small "-ngày 9/1: câu 1, 4, 5 + Đ.2" }
        \line { \small "-ngày 10/1: câu 1, 6, 7 + Đ.2" }
        \line { \small "-cầu hòa bình: câu 1, 3, 5, 7 + Đ.1" }
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
