'use strict';

function LookThing(opts) {
  opts            = opts || {};

  this.images     = [];
  this.currentIdx = null;

  this.baseDir      = opts.baseDir || '';
  this.imageLicense = opts.imageLicense || null;

  this.buildImageList();
  this.createBox();
  this.createListeners();
}

LookThing.prototype.buildImageList = function() {
  var elems = document.querySelectorAll('*[data-lookthing]');
  var elem, attr, uri, i;

  for (i = 0; i < elems.length; i++) {
    elem = elems[i];
    attr = elem.getAttribute('data-lookthing');
    uri  = elem.getAttribute(attr);

    if (!uri) {
      uri = attr;
    }

    if (attr && uri) {
      this.images[i] = {
        uri:         uri,
        title:       elem.getAttribute('data-lookthing-title'),
        description: elem.getAttribute('data-lookthing-desc'),
        date:        elem.getAttribute('data-lookthing-date'),
        attribution: {
          name: elem.getAttribute('data-lookthing-attribution-name'),
          uri:  elem.getAttribute('data-lookthing-attribution-uri'),
        }
      };

      elem.addEventListener('click', function(idx) {
        return function(event) {
          event.preventDefault();
          this.turnOn(idx);
        };
      }(i).bind(this), false);
    }
  }
};

LookThing.prototype.createBox = function() {
  var div, a;

  this.box = document.createElement('div');
  this.box.className = 'lookthing-off';

  this.closeLink = this.createLink({ text: 'Close',
                                     click: this.turnOff });

  this.prevLink  = this.createLink({ text: 'Previous',
                                     click: this.showPrevious });
  this.nextLink  = this.createLink({ text: 'Next',
                                     click: this.showNext });

  this.canvas = document.createElement('div');
  this.canvas.className = 'canvas';
  this.box.appendChild(this.canvas);

  this.footer = document.createElement('div');
  this.footer.className = 'statusbar';
  this.box.appendChild(this.footer);

  //Image title
  div = document.createElement('div');
  div.className = 'title';
  this.footer.appendChild(div);

  this.imageTitle = document.createElement('a');
  this.imageTitle.setAttribute('href', '#');
  this.imageTitle.appendChild(document.createTextNode(''));
  div.appendChild(this.imageTitle);

  //Info
  div = document.createElement('div');
  div.className = 'info';
  this.footer.appendChild(div);

  this.imageDesc = document.createElement('span');
  this.imageDesc.appendChild(document.createTextNode(''));
  div.appendChild(this.imageDesc);

  //License
  div = document.createElement('div');
  div.className = 'license';
  this.footer.appendChild(div);

  div.appendChild(document.createTextNode('Author:'));

  this.workLink = document.createElement('a');
  this.workLink.setAttribute('href', '#');
  this.workLink.appendChild(document.createTextNode('Me'));
  div.appendChild(this.workLink);

  if (this.imageLicense.uri && this.imageLicense.name) {
    div.appendChild(document.createTextNode('License:'));

    a = document.createElement('a');
    a.setAttribute('href', this.imageLicense.uri);
    a.setAttribute('rel', 'license');
    a.appendChild(document.createTextNode(this.imageLicense.name));
    div.appendChild(a);
  }

  //Nav
  div = document.createElement('div');
  div.className = 'nav';
  this.footer.appendChild(div);

  div.appendChild(this.prevLink);
  div.appendChild(this.nextLink);
  div.appendChild(this.closeLink);

  document.body.appendChild(this.box);
};

LookThing.prototype.createLink = function(opts) {
  var a = document.createElement('a');
  a.className = 'button';
  a.setAttribute('href', '#');
  a.appendChild(document.createTextNode(opts.text));

  if (opts.click !== null) {
    a.addEventListener('click', function(evt) {
      if (evt && evt.preventDefault) {
        evt.preventDefault();
      }
      opts.click.call(this);
    }.bind(this));
  }
  return a;
};

LookThing.prototype.createListeners = function() {
  window.addEventListener('keydown', function(evt) {
    evt = evt || window.event;

    if (evt.keyCode == 27 || evt.key == 'Escape' || evt.key == 'Esc') {
      this.turnOff();
    } else if (evt.keyCode == 8  || evt.key == 'Backspace' ||
               evt.keyCode == 37 || evt.key == 'Left' || evt.key == 'ArrowLeft') {
      this.showPrevious();
    } else if (evt.keyCode == 32 || evt.key == ' '     || evt.key == 'Spacebar' ||
               evt.keyCode == 39 || evt.key == 'Right' || evt.key == 'ArrowRight') {
      this.showNext();
    } else {
      return;
    }

    if (evt.preventDefault) {
      evt.preventDefault();
    }

  }.bind(this), true);
};

LookThing.prototype.turnOff = function() {
  this.box.className = 'lookthing lookthing-off';
  this.currentIdx    = null;
};

LookThing.prototype.turnOn = function(idx) {
  var image = this.images[idx];
  if (!image) {
    return;
  }

  this.box.className = 'lookthing lookthing-on';
  this.canvas.style.backgroundImage = 'url(' + image.uri + '), url(' + this.baseDir + 'loading.png)';

  this.prevLink.className = (idx === 0) ? 'button off' : 'button on';
  this.nextLink.className = (idx === this.images.length - 1) ? 'button off' : 'button on';

  if (this.imageTitle.textContent !== undefined) {
    this.imageTitle.textContent = image.title || 'Image';
  }
  this.imageTitle.setAttribute('href', image.uri);

  if (this.imageDesc.textContent !== undefined) {
    this.imageDesc.textContent = image.description || '';
  }

  if (this.workLink.textContent !== undefined) {
    this.workLink.textContent = image.attribution.name || 'Me';
  }
  this.workLink.setAttribute('href', image.attribution.uri || '#');

  this.currentIdx = idx;
};

LookThing.prototype.shiftCurrent = function(direction) {
  if (this.currentIdx === null) {
    return 0;
  }
  var idx = this.currentIdx + direction;
  if (idx < 0) {
    idx = 0;
  } else if (idx >= this.images.length) {
    idx = this.images.length - 1;
  }
  return idx;
};

LookThing.prototype.showNext = function() {
  this.turnOn(this.shiftCurrent(1));
};

LookThing.prototype.showPrevious = function() {
  this.turnOn(this.shiftCurrent(-1));
};
