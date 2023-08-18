% Cài đặt chung
\version "2.22.1"
\include "english.ly"

\header {
  title = "Thánh Vịnh 109"
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
  \partial 8 b8 |
  <<
    {
      \voiceOne
      a4.
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
  g16 c |
  c8. c16 \tuplet 3/2 { a8 d fs, } |
  g4 \tuplet 3/2 { b8 c b } |
  a8. g16 g8 e |
  e4 \tuplet 3/2 { e8 fs e } |
  d4. d16 e |
  b8 d \tuplet 3/2 { fs8 a g } |
  g4 r8 \bar "||"
}

nhacPhanHai = \relative c'' {
  \key g \major
  \time 2/4
  \partial 8 g |
  e4 \tuplet 3/2 { e8 d d } |
  <<
    {
      b'4. a16 d |
      fs,8 g a g |
      g4 r8
    }
    {
      g4. fs16 e |
      d8 e c c |
      b4 r8
    }
  >>
  \bar "|."
}

nhacPhanBa = \relative c'' {
  \key g \major
  \time 2/4
  \partial 8 g8 |
  e e4 d16 d |
  <<
    {
      b'4. a16 b |
      e,8 g a a |
      a4. d8 |
      d b
    }
    {
      g4. d16 d |
      c8 e c cs |
      d4. fs8 |
      g g
    }
  >>
  <<
    {
      \voiceOne
      a8 (b16 a)
    }
    \new Voice = "splitpart" {
      \voiceTwo
      fs4
    }
  >>
  \oneVoice
  g4 r8 \bar "|."
}

% Lời
loiPhanMot = \lyricmode {
  <<
    {
      \set stanza = "1."
      Sấm ngôn của Đức Chúa ngỏ cùng Chúa Thượng tôi:
      Bên hữu Cha đây Con lên ngự trị,
      rồi bao quân thù Cha sẽ đặt làm bệ dưới chân Con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "2."
      \override Lyrics.LyricText.font-shape = #'italic
      Chính nay, từ Si -- on tay
      Người sẽ mở rộng cho tới muôn nơi.
      Đây vương quyền Người, ngay giữa quân thù,
      mong nước Người hiển trị mãi khôn ngơi.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "3."
      Đức \markup { \underline "Chúa" } đà phán quyết:
      Con hãy nắm quyền uy,
      Đây lúc đăng quang, uy linh rạng ngời,
      hừng đông chưa dậy, từ cung lòng rầy
      Cha đã sinh Con.
    }
    \new Lyrics {
	    \set associatedVoice = "beSop"
	    \set stanza = "4."
      \override Lyrics.LyricText.font-shape = #'italic
      Đức \markup { \underline "Chúa" } thề hứa sẽ không hề rút lời đâu:
      Cho đến thiên thu, Con đây thực là Tư tế muôn đời
      theo đúng phẩm hàm Mel -- ki -- sê -- đê.
    }
  >>
}

loiPhanHai = \lyricmode {
  Muôn đời Con là Thượng Tế theo phẩm hàm Mel -- ki -- sê -- đê.
}

loiPhanBa = \lyricmode {
  Đức Ki -- tô là Thượng Tế
  theo phẩm hàm Mel -- ki -- sê -- đê đã tiến dâng bánh rượu.
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
        \line { \small "-t2 l /2TN: cả 4 câu + Đ.1" }
        \line { \small "-t4 l /2TN: cả 4 câu + Đ.1" }
        \line { \small "-t4 l /3TN: cả 4 câu + Đ.1" }
      }
    }
    \column {
      \left-align {
        \line { \small " " }
        \line { \small "-Mình Máu Chúa C: cả 4 câu + Đ.1" }
        \line { \small "-T.Mục tử: cả 4 câu + Đ.1" }
        \line { \small "-Truyền chức: cả 4 câu + Đ.2" }
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
    \override Lyrics.LyricSpace.minimum-distance = #0.45
    \override Score.BarNumber.break-visibility = ##(#f #f #f)
    \override Score.SpacingSpanner.uniform-stretching = ##t
    \override LyricHyphen.minimum-distance = #2.0
    ragged-last = ##f
  }
}
