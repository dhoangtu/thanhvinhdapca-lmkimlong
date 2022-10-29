% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 70"
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
  c8. f16 d8 d |
  c4. c8 |
  a'4 e8 e16 (f) |
  g8. a16 f8 e |
  d2 ~ |
  d8 c c d |
  e4 e8 f |
  f8. d16 f8 a |
  g4 a8 b |
  a8. g16 d'8 b |
  c2 ~ |
  c4 r \bar "||"
}

nhacPhanHai = \relative c'' {
  \key c \major
  \time 2/4
  <<
    {
      g8 a
    }
    {
      e d
    }
  >>
  <<
    {
      \voiceOne
      c'8 a16 (g)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      e8 c
    }
  >>
  \oneVoice
  <<
    {
      d8. f16 g8 g
    }
    {
      b,8. d16 b8 b
    }
  >>
  c2 ~ |
  c4 r \bar "|."
}

nhacPhanBa = \relative c' {
  \key c \major
  \time 2/4
  e4 e8 d |
  e4. f8 |
  d4 c8 c |
  <<
    {
      g'2 |
      r8 e a a |
      g4 a8 b |
      c2 \bar "|."
    }
    {
      b,2 |
      r8 c f f |
      e4 d8 d |
      e2
    }
  >>
}

nhacPhanBon = \relative c'' {
  \key c \major
  \time 2/4
  g8 c,
  <<
    {
      f8 (e) |
      d4. a'8 |
      g g a (b) |
      c2 \bar "|."
    }
    {
      a,8 (c) |
      b4. c8 |
      e e d (g) |
      e2
    }
  >>
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Con náu thân bên Ngài, lạy Chúa đừng để con thất vọng khi nào.
      Vì Ngài công minh, xin cứu vớt và giải thoát con,
      xin lắng nghe và tế độ con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Như núi con nương nhờ, lạy Chúa,
      tựa thành lũy cứu độ con này.
      Vạn lạy Thiên Chúa, ôi núi đá, thành lũy chở che
      cho thoát tay độc ác thù nhân.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Con vẫn luôn hy vọng vào Chúa,
      từ tuổi xuân đã tin cậy Ngài.
      Từ hồi thơ ấu con đã nép mình vào Chúa luôn,
      thai mẫu tay Ngài đã chở che.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Hôm sớm tôn vinh Ngài, lạy Chúa,
      này miệng con chứa chan bao lời.
      Ngày đời xế bòng, xin chớ thải hồi phần kiếp con,
      khi yếu suy Ngài chớ bỏ rơi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Con vẫn luôn trông cậy,
      và muôn lời tụng ca Chúa vang lên hoài.
      Này miệng con sẽ công bố Chúa thật là chính trung,
      loan báo ơn Ngài cứu độ liên.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Công bố lòng trung trực của Chúa,
      tường thuật ơn cứu độ của Ngài.
      Từ hồi niên thiếu, ôi chính Chúa từng dạy dỗ con,
      xin mãi rao truyền nhwungx kỳ công.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Loan báo uy công Ngài, lạy Chúa,
      và nhủ tâm: Chúa muôn công bình.
      Từ hồi niên thiếu, ôi chính Chúa từng dạy dỗ con,
      xin mãi rao truyền những kỳ công.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Xin mãi tri ân Ngài thành tín,
      và dạo lên những cung hạc cầm,
      Trọn niềm dâng Chúa, ôi Đấng Thánh của nhà Ích -- diên,
      câu tán dương hòa tiếng đàn tơ.
    }
  >>
}

loiPhanHai = \lyricmode {
  Miệng con sẽ loan truyền ơn Chúa cứu độ.
}

loiPhanBa = \lyricmode {
  Xin cho miệng con chứa chan lời ngợi khen,
  để con ca tụng vinh quang Chúa.
}

loiPhanBon = \lyricmode {
  Chúa đà kéo con ra khỏi lòng thân mẫu.
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
        \line { \small "-ngày 19/12: câu 2, 3, 7 + Đ.2" }
        \line { \small "-Cn C /4TN: câu 1, 2, 3, 6 + Đ.1" }
        \line { \small "-t7 c /9TN: câu 4, 5, 7, 8 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small "-t4 c /16TN: câu 1, 2, 3, 6 + Đ.1" }
        \line { \small "-t2 tuần Thánh: câu 1, 2, 3, 6 + Đ.1" }
        \line { \small "-vọng T.Gioan tiền hô: câu 1, 2, 3, 6 + Đ.3" }
        \line { \small "-cuộc khổ nạn Chúa (NL): câu 1, 2, 3, 6 + Đ.1" }
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
