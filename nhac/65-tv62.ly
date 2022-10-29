% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 62"
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
  g4. fs16 (g) |
  a4 \tuplet 3/2 { a8 g fs } |
  e4. d8 |
  g8. g16 \tuplet 3/2 { g8 g fs } |
  b8. b16 \tuplet 3/2 { a8 c e } |
  d8. b16 \tuplet 3/2 { d8 b g } |
  e4 \tuplet 3/2 { e8 g e } |
  d8. d16 \tuplet 3/2 { a'8 a d } |
  g,4 r8 \bar "||"
}

nhacPhanHai = \relative c' {
  \key g \major
  \time 2/4
  \partial 8 d8 |
  <<
    {
      b'8. b16 \tuplet 3/2 { c8 b g } |
      e4. e16 d |
      a'4 \tuplet 3/2 { c8 c d }
    }
    {
      g,8. g16 \tuplet 3/2 { e8 d d } |
      c4. c16 b |
      d4 \tuplet 3/2 { e8 e fs }
    }
  >>
  g2 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Thân lạy Chúa, Đấng con tôn thờ,
      Này con nao nao trông tìm Chúa,
      linh hồn con khát khao, thân xác con hao mòn,
      như đất khô cằn hằng trông mong nước nguồn.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Mong được tới ngắm tôn nhan Ngài,
      nhìn xem vinh quang uy lực Chúa.
      Ân tình của Chúa luôn cao quý hơn sinh mạng,
      Con muốn vang lời mà ca khen suốt đời.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Con nguyện ước chúc khen trọn đời,
      và xin giơ tay kêu cầu Chúa.
      Nay hồn con sướng vui như mới tham dự tiệc,
      Câu hát trên miệng, mừng vui hoan chúc Ngài.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Mơ tưởng Chúa mỗi khi lên giường,
      và qua năm canh con thầm nhắc.
      Bởi Ngài đã đoái thương luôn cứu nguy hộ phù,
      nương bóng tay Ngài, miệng con vui hát mừng.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Con được Chúa cứu nguy hộ phù,
      miệng con luôn reo vui mừng hát,
      tâm tình con Chúa ơi xin kết liên trong Ngài,
      Tay Chúa uy quyền hằng nâng niu dắt dìu.
    }
  >>
}

loiPhanHai = \lyricmode {
  Lạy Chúa, Thiên Chúa con tôn thờ,
  linh hồn con luôn khao khát Ngài.
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
        \line { \small "-t7 c /8TN: câu 1, 2, 3 + Đáp" }
        \line { \small "-Cn C /12TN: câu 1, 2, 3, 5 + Đáp" }
        \line { \small "-Cn A /22TN: câu 1, 2, 3, 5 + Đáp" }
        \line { \small "-Cn A /32TN: câu 1, 2, 3, 4 + Đáp" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-Rửa tội: câu 1, 2, 3, 5 + Đáp" }
        \line { \small "-Khấn dòng: câu 1, 2, 3, 5 + Đáp" }
        \line { \small "-T.Madalena: câu 1, 2, 3, 5 + Đáp" }
        \line { \small "-Cầu hồn: câu 1, 2, 3, 5 + Đáp" }
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
