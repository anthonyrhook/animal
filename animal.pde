/*
 * MIDI Drum Kit
 * -------------
 * Convert Arduino to a MIDI controller using various inputs and
 * the serial port as a MIDI output.
 *
 * This sketch is set up to send General MIDI (GM) drum notes 
 * on MIDI channel 1, but it can be easily reconfigured for other
 * notes and channels
 *
 * It uses switch inputs to send MIDI notes of a fixed velocity with
 * note on time determined by duration of keypress and it uses
 * piezo buzzer elements as inputs to send MIDI notes of a varying velocity
 * & duration, depending on forced of impulse imparted to piezo sensor.
 *
 * To send MIDI, attach a MIDI out jack (female DIN-5) to Arduino.
 * DIN-5 pinout is:                               _____ 
 *    pin 2 - Gnd                                /     \
 *    pin 4 - 220 ohm resistor to +5V           | 3   1 |  MIDI jack
 *    pin 5 - Arduino D1 (TX)                   |  5 4  |
 *    all other pins - unconnected               \__2__/
 * On my midi jack, the color of the wires for the pins are:
 *   3 = n/c 
 *   5 = black  (blue)
 *   2 = red    (red)
 *   4 = orange (yellow)
 *   1 = brown
 *
 * Based off of Tom Igoe's work at:
 *    http://itp.nyu.edu/physcomp/Labs/MIDIOutput
 *
 * Created 25 October 2006
 * copyleft 2006 Tod E. Kurt <tod@todbot.com
 * http://todbot.com/
 *
 * Updates:
 * - 2 May 2009 - fixed noteOn() and noteOff() 
 * - 19 July 2011 - Anthony Hook - rewrote most of the main loop, arrays for notes, sensors
 *
 */
 
//TODO Check for optimizations that can be done with piezo sensors
#define DRUMCHAN 1

// general midi drum notes
// bass, snare, hhc, hho, crash
#define NUM_NOTES 5
int notes[NUM_NOTES] = {35,48,42,44,49};


#define NUM_SWITCH 3
int switchPins[NUM_SWITCH] = {7,6,5};
int switchStates[NUM_SWITCH] = {LOW,LOW,LOW};
int currentSwitchState = LOW;

#define NUM_PIEZO 2
int piezoPins[NUM_PIEZO] = {0,1};
int notesPiezo[NUM_PIEZO] = {44,49};

//midi out streams
#define LEDPIN 13

//analog threshold for piezo sensing
#define PIEZOTHRESHOLD 100

//Apparently notes are as follows:
//Switchpins 1,2,3: bass, snare, hhc

void setup() {
  for (int i=0; i < NUM_SWITCH; i++) {
    pinMode(switchPins[i], INPUT);
    digitalWrite(switchPins[i], HIGH);
  }

  pinMode(LEDPIN, OUTPUT);
  Serial.begin(31250);   // set MIDI baud rate
}

void loop() {
  for (int i=0; i < NUM_SWITCH; i++) {
    currentSwitchState = digitalRead(switchPins[i]);
    if (currentSwitchState == LOW && switchStates[i] == HIGH ) // push
      noteOn(DRUMCHAN,  notes[i], 100);

    if (currentSwitchState == HIGH && switchStates[i] == LOW ) // release
      noteOff(DRUMCHAN, notes[i], 0);
    switchStates[i] = currentSwitchState;
  }

  //Specially deal with piezos for hho, crash
  for (int i = 0; i < NUM_PIEZO; i++) {
    int val = analogRead(piezoPins[i];
    if (val >= PIEZOTHRESHOLD {
      int t = 0;
      while (analogRead(piezoPins[i]) >= PIEZOTHRESHOLD/2 {
        t++;
      }
    noteOn(DRUMCHAN, notesPiezo[i], t*2);
    delay(t);
    noteOff(DRUMCHAN, notesPiezo[i], 0);
    }
  }
}

// Send a MIDI note-on message.  Like pressing a piano key
// channel ranges from 0-15
void noteOn(byte channel, byte note, byte velocity) {
  midiMsg ((0x90 | channel), note, velocity);
}

// Send a MIDI note-off message.  Like releasing a piano key
void noteOff(byte channel, byte note, byte velocity) {
  midiMsg( (0x80 | channel), note, velocity);
}

// Send a general MIDI message
void midiMsg(byte cmd, byte data1, byte data2) {
  digitalWrite(LEDPIN,HIGH);  // indicate we're sending MIDI data
  Serial.print(cmd, BYTE);
  Serial.print(data1, BYTE);
  Serial.print(data2, BYTE);
  digitalWrite(LEDPIN,LOW);
}
