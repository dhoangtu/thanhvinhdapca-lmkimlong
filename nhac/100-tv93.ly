% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 93"
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
  \partial 8
  <<
    {
      \voiceOne
      a8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #3
      \tweak font-size #-2
      \parenthesize
      b
    }
  >>
  \oneVoice
  b4 \tuplet 3/2 { a8 g d } |
  e4. e16 a |
  c8. b16 \tuplet 3/2 { a8 f' d } |
  e4 r8 d16 d |
  e4 \tuplet 3/2 { d8 c a } |
  b4. g16 a |
  e8. e16 \tuplet 3/2 { d'8 c a } |
  a4 r8 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key c \major
  \time 2/4
  \partial 8
  <<
    {
      c8 |
      b2 ~ |
      b8
    }
    {
      a8 |
      e2 ~ |
      e8
    }
  >>
  e8
  <<
    {
      \voiceOne
      b'16 (c) b8
    }
    \new Voice = "splitpart" {
      \voiceTwo
      d,8 d
    }
  >>
  \oneVoice
  <a' c,>2 ~ |
  <a c,>4 r8 \bar "|."
}

nhacPhanBa = \relative c' {
  \key c \major
  \time 2/4
  \partial 8 e8 |
  <<
    {
      c'2 |
      b16 (c) a8 a e' |
      e2 |
    }
    {
      a,2 |
      gs16 (a) f8 e a |
      gs2
    }
  >>
  e8 e \stemDown <c' ^( a > <b) gs> |
  \stemNeutral a2 ~ |
  a4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Ôi Chúa, dân riêng Ngài chọn,
      bọn gian ác nay dày xéo tàn hung,
      Đang tâm giết bao quả phụ luôn,
      diệt ngoài kiều và mưu sát cô nhi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      \markup { \underline "Chúng" } nói: Chúa đâu còn nhìn,
      chẳng lưu ý đâu nào, Chúa Gia -- cóp.
      Quân ngu dốt hãy mau để tâm,
      bọn điên dại ngày nao mới nên khôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      \markup { \underline "Đấng" } gắn lỗ tai từng người,
      nặn ra mắt sao chẳng thấy chẳng nghe.
      Vua minh xét không luận phạt sao?
      Dạy bao người mà không rõ chi sao?
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Ôi Chúa, phúc cho kẻ nào được Thiên Chúa đem luật pháp bảo ban,
      ngay khi mắc tai họa hiểm nguy,
      họ vẫn được bình an vững tâm luôn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Dân Chúa, Chúa đây ruồng rẫy, sản nghiệp Chúa đâu Ngài nỡ bỏ rơi.
      Cho công lý đem lại kỷ cương,
      để tâm hồn người công chính tuân theo.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Khi Chúa không thương phù trợ,
      thì con sẽ rơi vào cõi lặng thinh.
      Khi con nói: Con đã chồn chân,
      tình thương Ngài liền nâng đỡ con lên.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Con nói: chân con chồn rồi,
      tình thương Ngài đã vội đỡ nâng con.
      Khi tâm trí mang nặng sầu lo,
      Ngài an ủi làm con sướng vui lên.
    }
  >>
}

loiPhanHai = \lyricmode {
  Chúa không ruồng rẫy dân Ngài.
}

loiPhanBa = \lyricmode {
  Lạy Chúa, kẻ được Ngài giáo huấn thực hạnh phúc thay.
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
  page-count = 2
}

\markup {
  \vspace #1
  %\fill-line {
    \column {
      \left-align {
        \line { \bold \small "Sử dụng:" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t3 c /6TN: câu 4, 5, 6 + Đ.2" }
        \line { \small "-t4 c /15TN: câu 1, 2, 3, 5 + Đ.1" }
        \line { \small "-t7 l /30TN: câu 4, 5, 6 + Đ.1" }
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
