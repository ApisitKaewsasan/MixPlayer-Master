
enum PlayerState {
  none,
 ready,
 running,
 playing,
 bufferring,
  complete,
 paused,
 stopped,
 error,
 disposed,
}



class PlayerStateGet {
  static PlayerState getPlayerState(String event) {
    if (event == 'ready') {
      return PlayerState.ready;
    } else if (event == 'running') {
      return PlayerState.running;
    } else if (event == 'playing') {
      return PlayerState.playing;
    } else if (event == 'bufferring') {
      return PlayerState.bufferring;
    }else if (event == 'complete') {
      return PlayerState.complete;
    }else if (event == 'paused') {
      return PlayerState.paused;
    }else if (event == 'stopped') {
      return PlayerState.stopped;
    }else if (event == 'error') {
      return PlayerState.error;
    }else {
      return PlayerState.disposed;
    }
  }
}

