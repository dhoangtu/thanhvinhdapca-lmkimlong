% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 77"
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
  \partial 8 g16 g |
  g4 \tuplet 3/2 { g8 g b } |
  e,4. fs16 e |
  d4 \tuplet 3/2 { fs8 g b } |
  a2 ~ |
  a4 r8 c16 c |
  e4 \tuplet 3/2 { c8 a d } |
  fs,4. e16 fs |
  d4 \tuplet 3/2 { d8 a' fs } |
  g2 ~ |
  g4 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key g \major
  \time 2/4
  \partial 4 d8 b16 (a) |
  e8 (g4)
  <<
    {
      b8 |
      a4 a8 a |
      c4. c8
    }
    {
      g8 |
      fs4 fs8 fs |
      e4. fs8
    }
  >>
  g4 r8 \bar "|."
}

nhacPhanBa = \relative c'' {
  \key g \major
  \time 2/4
  \partial 4
  <<
    {
      b8 a |
      b4. a16 (g) |
      e8 (d) a' b |
      g2 ~ |
      g4 r8 \bar "|."
    }
    {
      g8 fs |
      g4. a16 (g) |
      c,8 (b) c d |
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
      Muôn dân ơi nghe tôi giảng dạy,
      lắng nghe lời miệng tôi nói đây.
      Tôi tuyên bố đôi lời huấn dụ,
      công bố điều huyền bí thuở xưa.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Nghe cha ong xưa kia kể lại,
      hãy loan truyền để con cháy hay:
      Sự nghiệp Chúa bao là lẫy lừng,
      tay Chúa từng làm những kỳ công.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Cho mai sau luân phiên kể lại
      để miêu duệ cậy tin Chúa luôn.
      Không quên lãng bao việc Chúa làm,
      luôn giữ trọn lệnh Chúa truyền ban.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      không noi theo cha ông ngỗ nghịch,
      những lăng loàn và ngoan cố luôn.
      Ôi tông giống tâm địa thất thường,
      không tín thành, chẳng có thủy chung.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "5."
      Khi manh tâm trêu ngươi Chúa Trời:
      chúng đã đòi được ăn thỏa thuê.
      Kêu than Chúa: nơi rừng vắng này,
      liệu Chúa dọn được thức gì ăn?
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "6."
      \override Lyrics.LyricText.font-shape = #'italic
      Mây cao xanh vâng theo Chúa truyền,
      cánh cửa trời, Ngài đã hé ra,
      man -- na rớt như là mưa rào:
      nuôi dưỡng họ bằng bánh trời ban.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "7."
      Nhân gian nay no nê mãn nguyện,
      bánh thiên thần rầy họ đã ăn.
      Phụng lệnh Chúa, gió đông nổi dậy
      tung sức Ngài gọi gió miền nam.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "8."
      \override Lyrics.LyricText.font-shape = #'italic
      Nhân gian nay no nê mãn nguyện,
      bánh thiên thần rầy họ đã ăn,
      Đưa dân tới ống trong thánh địa,
      Tay hữu Ngài dựng núi gầy non.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "9."
      Chung quanh nơi dân đang trú ngụ
      giữa doanh trại Ngài đã khiến cho
      chim sa xuống như là cát biển,
      Mưa trút thịt nhiều quá bụi tro.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "10."
      \override Lyrics.LyricText.font-shape = #'italic
      Khi nguy cơ sa tay Chúa phạt,
      chúng trở lại vội tìm Chúa ngay,
      và tưởng nhớ ơn Ngài cứu độ,
      Xin Chúa Trời thành núi ẩn thân.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "11."
      Dân điêu ngoa chuyên gian dối Ngài,
      Lưỡi phỉnh phờ, lường gạt Chúa luôn.
      Lòng dạ chúng chẳng hề tín thành,
      GIa ước Ngài, nào có thực thi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "12."
      \override Lyrics.LyricText.font-shape = #'italic
      Nhưng khoan dung, không tiêu hủy họ,
      Chúa nhân từ dủ tình thứ tha,
      và kiềm chế bao là oán hờn,
      chẳng khơi bùng nộ khí Ngài lên.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "13."
      Dân manh tâm trêu ngươi Chúa Trời,
      Chẳng tuân hành lệnh Ngài đã ban:
      như tiền bối xa lìa, phản bội,
      thay đổi lòng tựa bắn lệch cung.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "14."
      \override Lyrics.LyricText.font-shape = #'italic
      Trên nơi cao, dân trêu tức Ngài:
      Kính ngẫu tượng, làm Ngài phát ghen,
      nên nay Chúa nổi bừng nghĩa nộ,
      nghiêm khắc loại nhà Is -- ra -- el.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "15."
      Trao vinh quang qua tay kẻ thù,
      khiến chúng đoạt hòm bia thánh luôn,
      bao chê chán dân Ngài đã chọn,
      nên phó mặc họ dới làn gươm.
    }
  >>
}

loiPhanHai = \lyricmode {
  Chúng tôi chẳng lãng quên mọi kỳ công Chúa làm.
}

loiPhanBa = \lyricmode {
  Chúa ban bánh bởi trời nuôi dưỡng họ.
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
        \line { \small "-t6 l /1TN: câu 2, 3, 4 + Đ.1" }
        \line { \small "-t4 l /16TN: câu 5, 6, 7, 9 + Đ.2" }
        \line { \small "-Cn B /18TN: câu 2, 6, 8 + Đ.2" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-t5 c /19TN: câu 13, 14, 15 + Đ.1" }
        \line { \small "-suy tôn Thánh giá: câu 1, 10, 11, 12 + Đ.1" }
        \line { \small "-Mình Máu Chúa (NL): câu 2, 6, 8 + Đ.2" }
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
