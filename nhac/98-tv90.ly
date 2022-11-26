% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 90"
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
  \partial 8 d8 |
  a8. a16 g8 bf |
  bf a4 g8 |
  a8. a16 a8 a |
  d, e4 d8 |
  g g f (g) |
  a4 r8 a |
  a8. d16 c8 c |
  f, f16 f bf8 g |
  a g16
  <<
    {
      \voiceOne
      g16
    }
    \new Voice = "splitpart" {
      \voiceTwo
      \once \override NoteColumn.force-hshift = #2
      \parenthesize
      a
    }
  >>
  \oneVoice
  f8 e |
  d4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key f \major
  \time 2/4
  \partial 8d8 |
  <<
    {
      a'4 g8 g |
      f (g)
    }
    {
      f4 e8 e |
      d (e)
    }
  >>
  <<
    {
      \voiceOne
      f8 (e)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      c4
    }
  >>
  \oneVoice
  d2 ~ |
  d4 r8 \bar "|."
}

nhacPhanBa = \relative c' {
  \key f \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      f2 |
      g8 f d f |
      g4. g8 |
      a (g)
    }
    {
      f2 |
      e8 d bf d |
      c4. e8 |
      f (e)
    }
  >>
  <<
    {
      \voiceOne
      f8 (e)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      c4
    }
  >>
  \oneVoice
  d2 ~ |
  d4 r8 \bar "|."
}

nhacPhanBon = \relative c'' {
  \key f \major
  \time 2/4
  \partial 8 a8 |
  d, (e)
  <<
    {
      f8 g |
      a4 bf8 e, |
      e4. g8 |
      a (g)
    }
    {
      d8 e |
      f4 d8 d |
      c4. e8 |
      f (e)
    }
  >>
  <<
    {
      \voiceOne
      f8 (e)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      c4
    }
  >>
  \oneVoice
  d2 ~ |
  d4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Hỡi ai nương tựa Đấng Tối Cao, ai nép dưới bóng Đấng toàn năng,
      hãy thân thưa cùng Chúa: ngài là chốn con nương mình,
      là thành lũy chở che, con tin tưởng nơi Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Giữ cho không lọt lưới ác nhân, cho thát bước khốn quẫn diệt vong.
      Ngài uy linh phủ bóng.
      Bạn ẩn náu nơi tay Ngài,
      lòng thành tín Ngài nên như khiên mộc giữ gìn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Mũi tên ban ngày có vút bay, đêm tối có vắng ngắt lạnh xương,
      bạn không khi sợ hãi,
      Dù thần khí hay ôn dịch hoành hành
      giữa buổi trưa hay bao phủ đêm dài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Những tai ương bạn có mắc đâu, nguy khó có bén tới nhà đâu.
      Vì theo như lệnh Chúa,
      Ngài đà khiến bao thiên thần
      hằng gìn giữ bạn luôn trên muôn vạn nẻo đường.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Chính tay thiên thần sẽ đỡ nâng chân khỏi vấp đá lúc bạn đi.
      Và luôn tay gìn giữ, dù bạn dẵm lên beo hùm,
      dù đạp rắn hổ mang, hay sư tử long đầu.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Đỡ nâng ai nhận biết Thánh Danh, ai những gắn bó mãi cùng Ta,
      được Ta thương giải thoát.
      Họ cầu cứu, Ta nghe lời,
      ngày họ mắc hiểm nguy, Ta luôn ở cận kề.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Chính Ta thương giải thoát cứu nguy,
      bạn xuống phúc đức với hiển vinh,
      và gia tăng ngày sống.
      Tuổi thọ sẽ thêm miên trường
      và được hưởng đầy dư ơn \markup { \underline "cứu" } độ Ta này.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa, con tin tưởng nơi Ngài.
}

loiPhanBa = \lyricmode {
  Lạy Chúa, xin ở kề bên con trong lúc ngặt nghèo.
}

loiPhanBon = \lyricmode {
  Chúa truyền cho thiên sứ giữu gìn bạn trên khắp nẻo đường.
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
        \line { \small "-t2 c /9TN: câu 1, 6, 7 + Đ.1" }
        \line { \small "-t2 l /14TN: câu 1, 2, 6 + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-Cn C /1MC: câu 1, 4, 5, 6 + Đ.2" }
        \line { \small "-T.Thần hộ thủ: câu 1, 2, 3, 4 + Đ.3" }
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
